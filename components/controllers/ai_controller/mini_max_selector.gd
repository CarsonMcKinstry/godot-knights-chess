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

signal threads_done

func signal_threads_finished():
	threads_done.emit()

func choose(chess_board: ChessBoard, party: PartyController) -> MoveRecord:
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

class MiniMaxResult extends RefCounted:
	var move: MoveRecord
	var score: int
	
	func with_move(i_move: MoveRecord) -> MiniMaxResult:
		move = i_move
		return self

	func with_score(i_score: int) -> MiniMaxResult:
		score = i_score
		return self
		
