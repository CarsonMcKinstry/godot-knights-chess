class_name AiController extends Node

signal turn_finished
signal checkmate



enum Behavior {
	Random,
	Minimax
}

@export var party: PartyController
@export var chess_board: ChessBoard

@export var behavior: Behavior = Behavior.Random

@export var board_evaluator: BoardEvaluator
@export var move_randomizer: MoveRandomizer
@export var minimax_selector: MiniMaxSelector

func start_turn():
	
	if chess_board.is_checkmate(Constants.Side.Computer):
		checkmate.emit()
	else:
		var move: MoveRecord
		
		match behavior:
			Behavior.Random:
				move = move_randomizer.choose(chess_board, party)
			Behavior.Minimax:
				move = minimax_selector.choose(chess_board, party)

		if move != null:
			chess_board.enqueue_move(move)
		
			await chess_board.resolve_latest_move()
		
			turn_finished.emit()
		else:
			checkmate.emit()

func choose_at_random() -> MoveRecord:

	var all_possible_moves: Array[MoveRecord] = []
	
	for piece in party.get_pieces():
		var moves = piece.get_all_possible_moves()
		all_possible_moves.append_array(moves)
	
	all_possible_moves.shuffle()
	
	var move
	
	while !all_possible_moves.is_empty():
		var temp = all_possible_moves.pop_front()
		var is_valid_move = chess_board.validate_move(temp)
		
		if is_valid_move:
			move = temp
			break
			
	return move
