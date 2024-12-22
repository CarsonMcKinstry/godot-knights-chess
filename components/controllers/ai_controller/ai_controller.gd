class_name AiController extends Node

signal turn_finished

@export var party: PartyController
@export var chess_board: ChessBoard

func start_turn():
	
	var pawns: Array[Piece] = party.get_pieces()\
		.filter(func (piece: Piece): return piece.piece_type == Piece.PieceType.Pawn)

	var pawn = pawns[randi() % pawns.size()]

	var potential_positions = pawn.ai_select()

	var next_position = potential_positions[randi() % potential_positions.size()]
	
	
	pawn.movement_controller.move_to(
		chess_board.get_absolute_position(next_position)
	)
	
	pawn.move_calculator.is_first_move = false
	
	await pawn.movement_controller.finished_moving
	
	turn_finished.emit()
