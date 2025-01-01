class_name AiController extends Node

signal turn_finished
signal checkmate

signal threads_done

enum Behavior {
	Random,
	Minimax
}

@export var party: PartyController
@export var chess_board: ChessBoard

@export var behavior: Behavior = Behavior.Random
@export var exploration_depth: int = 1

@export var thread_count: int = OS.get_processor_count()

@export_file("*.json") var pst_file

@onready var pst_computer: Dictionary = load_pst()
@onready var pst_player: Dictionary = load_pst_player(pst_computer)

@onready var pst_opponent = {
	Constants.Side.Computer: pst_player,
	Constants.Side.Player: pst_computer
}

@onready var pst_self = {
	Constants.Side.Computer: pst_computer,
	Constants.Side.Player: pst_player
}

const PIECE_WEIGHTS = {
	Constants.PieceType.Pawn: 100,
	Constants.PieceType.Knight: 280,
	Constants.PieceType.Bishop: 320,
	Constants.PieceType.Rook: 479,
	Constants.PieceType.Queen: 929,
	Constants.PieceType.King: 60_000,
}

const MVV_LVA = {
	Constants.PieceType.Queen: 0,
	Constants.PieceType.Rook: 1,
	Constants.PieceType.Bishop: 2,
	Constants.PieceType.Knight: 3,
	Constants.PieceType.Pawn: 4,
	Constants.PieceType.King: 5
}

func start_turn():
	
	if chess_board.is_checkmate(Constants.Side.Computer):
		checkmate.emit()
	else:
		var move: MoveRecord
		
		match behavior:
			Behavior.Random:
				move = choose_at_random()
			Behavior.Minimax:
				var all_possible_moves = chess_board.get_all_possible_moves_for(Constants.Side.Computer)
				if all_possible_moves.is_empty():
					move = null
				else:
					var result = await choose_by_minimax_parallel(
						all_possible_moves,
						exploration_depth,
						Constants.Side.Computer,
						true
					)
					move = result["move"]

		if move != null:
			chess_board.enqueue_move(move)
		
			await chess_board.resolve_latest_move()
		
			turn_finished.emit()
		else:
			checkmate.emit()

func choose_at_random() -> MoveRecord:

	var all_possible_moves: Array[MoveRecord] = []
	
	for piece in party.get_pieces():
		all_possible_moves.append_array(piece.get_all_possible_moves())
	
	all_possible_moves.shuffle()
	
	var move
	
	while !all_possible_moves.is_empty():
		var temp = all_possible_moves.pop_front()
		var is_valid_move = chess_board.validate_move(temp)
		
		if is_valid_move:
			move = temp
			break
			
	return move

## ===== MiniMax Use Case =====
func choose_by_minimax(
	depth: int,
	curr_move: MoveRecord,
	side: Constants.Side,
	score: int,
	is_maximizing_player: bool,
	alpha: int = -INF,
	beta: int = INF
) -> MiniMaxResult:
	
	var possible_moves = chess_board.get_all_possible_moves_for(side)
	
	if depth == 0 || possible_moves.is_empty():
		return MiniMaxResult.new().with_move(curr_move).with_score(score)
	
	possible_moves = order_moves(possible_moves)
	
	
	var best_move: MoveRecord

	if is_maximizing_player:
		var max_score = -INF
		for move in possible_moves:
			move.apply()
			var move_score = evaluate_board(move, score, side)
			var next_result = choose_by_minimax(depth - 1, move, side, move_score, false, alpha, beta)
			move.undo()
			
			if next_result.score > max_score:
				max_score = next_result.score
				best_move = move
			
			alpha = max(alpha, max_score)
			if beta <= alpha:
				break  # Beta cutoff
				
		return MiniMaxResult.new().with_move(best_move).with_score(max_score)
	else:
		var min_score = INF
		for move in possible_moves:
			move.apply()
			var move_score = evaluate_board(move, score, side)
			var next_result = choose_by_minimax(depth - 1, move, side, move_score, true, alpha, beta)
			move.undo()
			
			if next_result.score < min_score:
				min_score = next_result.score
				best_move = move
				
			beta = min(beta, min_score)
			if beta <= alpha:
				break
				
		return MiniMaxResult.new().with_move(best_move).with_score(min_score)

var thread_pool: Array[Thread] = []
var results: Array = []
var mutex = Mutex.new()
var threads_finished = 0

func choose_by_minimax_parallel(moves: Array, depth: int, side: Constants.Side, is_maximizing_player: bool) -> MiniMaxResult:
	results = []
	thread_pool.clear()
	threads_finished = 0
	
	var chunks = split_move_into_chunks(moves, thread_count)
	
	for chunk in chunks:
		var thread = Thread.new()
		var thread_data = {
			"moves": chunk,
			"depth": depth,
			"side": side,
			"is_maximizing_player": is_maximizing_player
		}
		thread_pool.append(thread)
		thread.start(evaluate_chunk.bind(thread_data))
		
	
	await threads_done
		
	results.sort_custom(func(a, b): 
		return a["score"] > b["score"]
	)
	
	return results[0]["result"]

func evaluate_chunk(data: Dictionary) -> void:
	mutex.lock()
	var chunk = data["moves"]
	var depth = data["depth"]
	var side = data["side"]
	var is_maximizing_player = data["is_maximizing_player"]
	
	for move in chunk:
		
		move.apply()
		
		if chess_board.is_check(side):
			results.append({
				"result": MiniMaxResult.new().with_move(move).with_score(-INF),
				"score": -INF
			})
		elif chess_board.is_checkmate(Constants.get_opposing_side(side)):
			results.append({
				"result": MiniMaxResult.new().with_move(move).with_score(INF),
				"score": INF
			})
		else:
			var score = evaluate_board(move, 0, side)
			var minimax_result = choose_by_minimax(depth - 1, move, side, score, !is_maximizing_player)
			results.append({
				"result": minimax_result,
				"score": minimax_result.score
			})
		
		move.undo()
	threads_finished += 1
	
	if threads_finished == thread_pool.size():
		call_deferred("signal_threads_finished")
	
	mutex.unlock()

func signal_threads_finished():
	threads_done.emit()

func split_move_into_chunks(moves: Array[MoveRecord], num_chunks: int) -> Array:
	var chunk_size = ceil(moves.size() / num_chunks)
	
	var chunks: Array = []
	
	for i in range(0, moves.size(), chunk_size):
		chunks.append(moves.slice(i, chunk_size))
	
	return chunks

func evaluate_board(move: MoveRecord, prev_sum: int, side: Constants.Side) -> int:
	var new_sum = prev_sum

	if chess_board.in_checkmate():
		if move.side == side:
			return 10 ** 10
		else:
			return -(10 ** 10)
	
	# need checks for draw, threefold repition, and stalemate
	# in these cases, return 0
	
	if chess_board.in_check():
		if move.side == side:
			new_sum += 50
		else:
			new_sum -= 50
	
	var from = move.from
	var to = move.to
	
	if prev_sum < -1500:
		if move.piece.piece_type == Constants.PieceType.King:
			move.is_end_game = true
		elif move.captured != null && move.captured.piece_type == Constants.PieceType.King:
			move.is_end_game = true
			
	if move.captured != null:
		var captured = move.captured.piece_type
		if move.side == side:
			new_sum += _get_weight(captured) + _get_position_value(pst_opponent, move.side, captured, move.is_end_game, to)
		else:
			new_sum -= _get_weight(captured) + _get_position_value(pst_self, move.side, captured, move.is_end_game, to)
	
	if move.promoted_to != null:
		var original_piece_type = move.piece.piece_type
		var promoted_to = move.promoted_to
		
		var change_from_original = _get_weight(original_piece_type) + _get_position_value(pst_self, move.side, original_piece_type, move.is_end_game, from)
		var change_from_promotion = _get_weight(promoted_to) + _get_position_value(pst_self, move.side, promoted_to, move.is_end_game, to)
		
		if move.side == side:
			new_sum -= change_from_original
			new_sum += change_from_promotion
		else:
			new_sum += change_from_original
			new_sum -= change_from_promotion
	else:
		var piece_type = move.piece.piece_type
		var from_change = _get_position_value(pst_self, move.side, piece_type, move.is_end_game, from)
		var to_change = _get_position_value(pst_self, move.side, piece_type, move.is_end_game, to)
		
		if move.side == side:
			new_sum += from_change
			new_sum -= to_change
		else:
			new_sum -= from_change
			new_sum += to_change

	return new_sum

func order_moves(moves: Array[MoveRecord]) -> Array[MoveRecord]:
	
	var scored_moves: Array = []
	
	for move in moves:
		var score = 0
		
		if move.captured != null:
			score += MVV_LVA[move.piece.piece_type] + 10 * PIECE_WEIGHTS[move.captured.piece_type]
		if move.promoted_to != null:
			score += 900
		if _is_central_square(move.to):
			score += 50
		
		scored_moves.append({ "move": move, "score": score })
		
	scored_moves.sort_custom(func(a, b):
		return a["score"] > b["score"]
	)
	
	var final_moves: Array[MoveRecord] = []
	
	for entry in scored_moves:
		final_moves.append(
			entry["move"]
		)
	
	return final_moves
	
func _is_central_square(pos: Vector2) -> bool:
	return pos.x in [3,4] and pos.y in [3,4]

func _get_weight(piece_type: Constants.PieceType) -> int:
	assert(piece_type in PIECE_WEIGHTS, "Weight not found for %s" % [Constants.piece_type_to_string(piece_type)])
	
	return PIECE_WEIGHTS.get(piece_type)

func _get_position_value(
	table: Dictionary,
	side: Constants.Side,
	piece_type: Constants.PieceType,
	is_end_game: bool,
	pos: Vector2
) -> int:
	
	var piece_short_code: String
	
	match piece_type:
		Constants.PieceType.Pawn:
			piece_short_code = "p"
		Constants.PieceType.Knight:
			piece_short_code = "n"
		Constants.PieceType.Bishop:
			piece_short_code = "b"
		Constants.PieceType.Rook:
			piece_short_code = "r"
		Constants.PieceType.Queen:
			piece_short_code = "q"
		Constants.PieceType.King:
			if is_end_game:
				piece_short_code = "k_e"
			else:
				piece_short_code = "k"

	var value_lookup = table[side]
	
	assert(value_lookup != null, "No lookup table found for %s " % [Constants.side_to_string(side)])

	var piece_values = value_lookup[piece_short_code]
	
	assert(piece_values, "No piece values found for %s " % [piece_short_code])

	return piece_values[pos.x][pos.y]

# ===== PST LOADERS =====
func load_pst():
	if FileAccess.file_exists(pst_file):
		var data_file = FileAccess.open(pst_file, FileAccess.READ)
		
		var json = JSON.new()
		var parsed_pst = json.parse_string(data_file.get_as_text())
		
		if parsed_pst is Dictionary:
			return parsed_pst
		else:
			print("Error reading file")
	else:
		print("File doesn't exist!")

func load_pst_player(pst: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	
	for key in pst.keys():
		var values = pst[key].duplicate();
		values.reverse()
		out[key] = values
	
	return out

class MiniMaxResult extends RefCounted:
	var move: MoveRecord
	var score: int
	
	func with_move(i_move: MoveRecord) -> MiniMaxResult:
		move = i_move
		return self

	func with_score(i_score: int) -> MiniMaxResult:
		score = i_score
		return self
		
