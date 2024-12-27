class_name AiController extends Node

signal turn_finished

@export var party: PartyController
@export var chess_board: ChessBoard

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

var running_sum := 0
var position_count = 0

func start_turn():
	turn_finished.emit()

func evaluate_board(
	move: MoveRecord,
	prev_sum: int,
	side: Constants.Side
):
	var tmp = prev_sum
	var from = move.from - Vector2.ONE
	var to = move.from - Vector2.ONE
	
	if tmp <= -1500:
		if move.piece.piece_type == Constants.PieceType.King:
			move.is_endgame = true
		elif move.captured != null && move.captured.piece_type == Constants.PieceType.King:
			move.is_captured_endgame = true

	if move.captured != null:
		var pst = pst_opponent if move.side == side else pst_self
		var weight = PIECE_WEIGHTS[move.captured.piece_type]
				
		var pst_values = pst[move.side]
		var pst_for_piece = pst_values[get_pst_key(move.captured, move.is_captured_endgame)]
	
		var pos_value = pst_for_piece[to.x][to.y]
		
		if move.side == side:
			tmp += pos_value
		else:
			tmp -= pos_value

	# eventually handle promotion...
	if move.pawn_promoted_to != null:
		
		var piece_weight = PIECE_WEIGHTS[move.piece.piece_type]
		var prom_weight = PIECE_WEIGHTS[move.pawn_promoted_to]
		
		var from_pos_value = pst_self[move.side][get_pst_key(move.piece)][from.x][from.y]
		var to_pos_value = pst_self[move.side][get_pst_key(move.piece)][to.x][to.x]
		
		if move.side == side:
			tmp -= piece_weight + from_pos_value
			tmp += prom_weight + to_pos_value
		else:
			tmp += piece_weight + from_pos_value
			tmp -= prom_weight + to_pos_value
	else:
		var from_pos_value = pst_self[move.side][get_pst_key(move.piece, move.is_endgame)][from.x][from.y]
		var to_pos_value = pst_self[move.side][get_pst_key(move.piece, move.is_endgame)][to.x][to.y]
		
		if move.side == side:
			tmp += from_pos_value
			tmp -= to_pos_value
		else:
			tmp -= from_pos_value
			tmp += to_pos_value
			
	return tmp
	
func minimax(game: BoardEvaluator, depth: int, is_maximizing_player: bool, sum: int, side: Constants.Side):
	position_count += 1
	
	var moves = game.get_all_possible_moves(side)
	
	moves.shuffle()
	
	if depth == 0 || moves.is_empty():
		return [null, sum]
		
	
	var max_value = -INF
	var min_value = INF
	
	var best_move: MoveRecord
	
	for move in moves:
		
		var original_game_state = game.simulate_move(move)
		
		var new_sum = evaluate_board(move, sum, side)
		
		var results = minimax(game, depth - 1, !is_maximizing_player, new_sum, side)
		
		var child_best_move = results[0]
		var child_value = results[1]
		
		game.undo_simulation(original_game_state)
		
		if is_maximizing_player:
			if child_value > max_value:
				max_value = child_value
				best_move = child_best_move
		else:
			if child_value < min_value:
				min_value = child_value
				best_move = move
		
		return [best_move, max_value if is_maximizing_player else min_value]

# ===== UTILS =====

func get_pst_key(piece: Piece, is_endgame: bool = false) -> String:
	match piece.piece_type:
		Constants.PieceType.Pawn:
			return "p"
		Constants.PieceType.Knight:
			return "n"
		Constants.PieceType.Bishop:
			return "b"
		Constants.PieceType.Rook:
			return "r"
		Constants.PieceType.Queen:
			return "q"
		Constants.PieceType.King:
			return "k" if !is_endgame else "k_e"
	return ""

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
	
