class_name MiniMaxSelector extends MoveSelector

const MVV_LVA = {
	Constants.PieceType.Queen: 0,
	Constants.PieceType.Rook: 1,
	Constants.PieceType.Bishop: 2,
	Constants.PieceType.Knight: 3,
	Constants.PieceType.Pawn: 4,
	Constants.PieceType.King: 5
}

@export var exploration_depth: int = 1
@export var thread_count: int = OS.get_processor_count()

@export var board_evaluator: BoardEvaluator

signal threads_done

func signal_threads_finished():
	threads_done.emit()

func choose(chess_board: ChessBoard, party: PartyController) -> MoveRecord:
	
	var all_possible_moves = chess_board.get_all_possible_moves_for(Constants.Side.Computer)
	
	if all_possible_moves.is_empty():
		return null
	
	#var all_possible_moves = chess_board.get_all_possible_moves_for(Constants.Side.Computer)
	#if all_possible_moves.is_empty():
		#move = null
	#else:
		#var result = await choose_by_minimax_parallel(
			#all_possible_moves,
			#exploration_depth,
			#Constants.Side.Computer,
			#true
		#)
		#move = result["move"]
	return null

func minimax(
	chess_board: ChessBoard,
	depth: int,
	is_maximizing_player: bool,
	score: int,
	side: Constants.Side,
	curr_move: MoveRecord
) -> MiniMaxResult:
	var possible_moves = chess_board.get_all_possible_moves_for(side)
	
	if depth == 0 || possible_moves.is_empty():
		return MiniMaxResult.new()\
				.with_move(curr_move)\
				.with_score(score)
	
	possible_moves.shuffle()
	
	var max_score = -INF
	var min_score = INF
	
	var best_move: MoveRecord
	
	for move in possible_moves:
		
		move.apply()
		var move_score = board_evaluator.evaluate_board(chess_board, move, score, side);
		
		var next_result = minimax(
			chess_board,
			depth - 1,
			!is_maximizing_player,
			move_score,
			side,
			move
		)
		
		move.undo()
		
		if is_maximizing_player:
			if next_result.score > max_score:
				max_score = next_result.score
				best_move = next_result.move
		else:
			if next_result.score < min_score:
				min_score = next_result.score
				best_move = next_result.move
				
				
	
	if is_maximizing_player:
		return MiniMaxResult.new().with_move(best_move).with_score(max_score)
	else:
		return MiniMaxResult.new().with_move(best_move).with_score(min_score)

class MiniMaxResult extends RefCounted:
	var move: MoveRecord
	var score: int
	
	func with_move(i_move: MoveRecord) -> MiniMaxResult:
		move = i_move
		return self

	func with_score(i_score: int) -> MiniMaxResult:
		score = i_score
		return self
		
