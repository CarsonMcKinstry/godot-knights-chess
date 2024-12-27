class_name AiController extends Node

signal turn_finished

@export var party: PartyController
@export var chess_board: ChessBoard

#const PIECE_VALUES = {
	#Constants.PieceType.Pawn: 100,
	#Constants.PieceType.Knight: 350,
	#Constants.PieceType.Bishop: 350,
	#Constants.PieceType.Rook: 525,
	#Constants.PieceType.Queen: 1000,
	#Constants.PieceType.King: 10000,
#}

#const POSITION_VALUES = {
	#Constants.PieceType.Pawn: [
		#[0, 0, 0, 0, 0, 0, 0, 0],
		#[50, 50, 50, 50, 50, 50, 50, 50],
		#[10, 10, 20, 30, 30, 20, 10, 10],
		#[5, 5, 10, 25, 25, 10, 5, 5],
		#[0, 0, 0, 20, 20, 0, 0, 0],
		#[5, -5, -10, 0, 0, -10, -5, 5],
		#[5, 10, 10, -20, -20, 10, 10, 5],
		#[0, 0, 0, 0, 0, 0, 0, 0]
	#],
	#Constants.PieceType.Knight: [
		#[-50, -40, -30, -30, -30, -30, -40, -50],
		#[-40, -20, 0, 0, 0, 0, -20, -40],
		#[-30, 0, 10, 15, 15, 10, 0, -30],
		#[-30, 5, 15, 20, 20, 15, 5, -30],
		#[-30, 0, 15, 20, 20, 15, 0, -30],
		#[-30, 5, 10, 15, 15, 10, 5, -30],
		#[-40, -20, 0, 5, 5, 0, -20, -40],
		#[-50, -40, -30, -30, -30, -30, -40, -50]
	#]
#}
#
#const CHECK_STATE = -1;

func start_turn():
	#var move := await pick_move()
#
	#assert(move != null, "Computer couldn't find a move to make...move.piece._ref.move_to(move.target)")
	#
	#move.piece._ref.move_to(move.target)	
	#
	#await move.piece._ref.finished_moving
	
	turn_finished.emit()
#
#func pick_move() -> BoardEvaluator.Move:
#
	#var board = BoardEvaluator.new(chess_board)
	#var moves = board.get_all_possible_moves(Constants.Side.Computer)
	#moves.shuffle()
	#
	#var best_move: BoardEvaluator.Move
	#var best_move_value: int = -INF
	#
	#if board.get_board_state().has(Constants.BoardState.Check_Computer):
		#for move in moves:
			#var score = evaluate_check_escape(board, move)
			#if score > best_move_value:
				#best_move_value = score
				#best_move = move
		#return best_move
	#
	#for move in moves:
		#var score = evaluate_simple_move(board, move)
		#if score > best_move_value:
			#best_move_value = score
			#best_move = move
	#
	#return best_move
#
#func evaluate_check_escape(board: BoardEvaluator, move: BoardEvaluator.Move) -> int:
	#var state = board.simulate_move(move)
	#var score = -INF
	#
	#if !board.get_board_state().has(Constants.BoardState.Check_Computer):
		#score = evaluate_board(board) + 1000 # Heavy bonus for escaping check
		#
	#board.undo_simulation(state)
	#return score
#
#func evaluate_simple_move(board: BoardEvaluator, move: BoardEvaluator.Move) -> int:
	#var state = board.simulate_move(move)
	#var score = evaluate_board(board)
   #
	## Check if move puts us in check
	#if board.get_board_state().has(Constants.BoardState.Check_Computer):
		#score = -INF
	## Bonus for putting opponent in check
	#elif board.get_board_state().has(Constants.BoardState.Check_Player):
		#score += 500
	   #
	#board.undo_simulation(state)
	#return score
#
#func evaluate_board(board: BoardEvaluator) -> int:
	#var score = 0
	#
	#for piece in board.player + board.computer:
		#var value = PIECE_VALUES[piece.type]
		#var pos_value = evaluate_position(piece)
		#
		#if piece.side == Constants.Side.Player:
			#score += value + pos_value
		#else:
			#score -= value + pos_value
	#
	#return score	
#
#func _calculate_move_score(board: BoardEvaluator, move: BoardEvaluator.Move, depth: int) -> int:
	#var original_state = board.simulate_move(move)
	#
	#if board.get_board_state().has(Constants.BoardState.Check_Computer):
		#board.undo_simulation(original_state)
		#return CHECK_STATE
		#
	#var score = evaluate_board(board)
	#
	#if depth > 0:
		#var opponent_moves = board.get_all_possible_moves(Constants.Side.Player)
		#var best_opponent_score = INF
		#
		#for opponent_move in opponent_moves:
			#var opponent_score = -_calculate_move_score(board, opponent_move, depth - 1)
			#best_opponent_score = min(best_opponent_score, opponent_score)
		#
		#score = (score + best_opponent_score) / 2
		#
	#
	#board.undo_simulation(original_state)
	#return score
#
#func evaluate_move(board: BoardEvaluator, move: BoardEvaluator.Move, depth: int = 2) -> void:
	#var score = _calculate_move_score(board, move, depth)
	#move_evaluated.emit(score)
#
#func evaluate_position(piece: BoardEvaluator.EvaluatorPiece) -> int:
	#var pos = piece.position - Vector2.ONE
	#
	#if piece.type in POSITION_VALUES:
		#var values = POSITION_VALUES[piece.type]
		#return values[pos.x][pos.y] if piece.side == Constants.Side.Computer else -values[7-pos.y][pos.x]
	#return 0
