class_name MoveRecord extends RefCounted

var side: Constants.Side

var from: Vector2
var to: Vector2

var piece: Piece
var captures: Piece

var is_endgame: bool = false

func _init(
	i_piece: Piece,
	i_side: Constants.Side,
	i_from: Vector2,
	i_to: Vector2
) -> void :
	side = i_side
	piece = i_piece
	from = i_from
	to = i_to
	
static func with_capture(
	i_piece: Piece,
	i_side: Constants.Side,
	i_from: Vector2,
	i_to: Vector2,
	i_capture: Piece
) -> MoveRecord:
	var record = MoveRecord.new(
		i_piece,
		i_side,
		i_from,
		i_to
	)
	
	record.captures = i_capture
	
	return record
