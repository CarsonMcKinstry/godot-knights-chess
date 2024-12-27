class_name MoveRecord extends RefCounted

var side: Constants.Side

var from: Vector2
var to: Vector2

var piece: Piece

var captured: Piece
var promoted_to: Constants.PieceType

var castled: Piece

func _init(
	i_side: Constants.Side,
	i_piece: Piece,
	i_from: Vector2,
	i_to: Vector2
):
	side = i_side
	piece = i_piece
	from = i_from
	to = i_to
	
func with_captured(i_piece: Piece) -> MoveRecord:
	
	captured = i_piece
	
	return self
	
func promoted(type: Constants.PieceType) -> MoveRecord:
	
	promoted_to = type
	
	return self

func with_castled(i_piece: Piece) -> MoveRecord:
	assert(piece.piece_type == Constants.PieceType.Rook)
	
	castled = i_piece
	
	return self

func with_target(target: Piece) -> MoveRecord:
	
	if piece.is_on_same_team_as(target):
		return with_castled(target)
	else:
		return with_captured(target)
	
	return self

func resolve(chess_board: ChessBoard) -> void:
	if captured != null:
		await piece.attack_target(captured)
	else:
		var pos = chess_board.get_canvas_position(piece.grid_position)
	
		await piece.move_to_position(pos)

func undo() -> void:
	piece.grid_position = from
	
	if captured != null:
		captured.is_dead = true

func apply() -> void:
	
	piece.grid_position = to

	if captured != null:
		captured.is_dead = true
