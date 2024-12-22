class_name AiController extends Node

signal turn_finished

@export var party: PartyController
@export var chess_board: ChessBoard

func start_turn():
	var move = pick_move()
	
	await get_tree().create_timer(0.5).timeout
	
	move.piece.ref.move_to(move.to_position)
	
	await move.piece.ref.finished_moving
	
	turn_finished.emit()

func pick_move() -> SimulatedMove:
	
	var simulated_board = SimulatedChessBoard.from(chess_board)
	
	var all_possible_moves = simulated_board.get_all_possible_moves()
	
	all_possible_moves.shuffle()
	
	var best_move_so_far: SimulatedMove
	var best_move_value: int = -INF
	
	for move in all_possible_moves:
		
		var score = simulated_board.evaluate_move(move)
		
		if score > best_move_value:
			best_move_so_far = move
			best_move_value = score
	
	return best_move_so_far
