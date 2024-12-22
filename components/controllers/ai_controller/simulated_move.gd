class_name SimulatedMove extends RefCounted


var piece: SimulatedPiece

var to_position: Vector2

static func from(
	i_piece: SimulatedPiece,
	i_to_position: Vector2
) -> SimulatedMove:
	var move = SimulatedMove.new()
	
	move.piece = i_piece
	move.to_position = i_to_position
	
	return move
