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

func debug() -> void:
	
	var piece_name = Constants.piece_type_to_string(piece.piece_type)
	
	if captured != null:
		print("%s at %s captures %s at %s" % [
			piece_name,
			from,
			Constants.piece_type_to_string(captured.piece_type),
			to
		])
	elif castled != null:
		pass
	else:
		print("%s at %s to %s" % [
			piece_name,
			from,
			to
		])

func with_captured(i_piece: Piece) -> MoveRecord:
	
	captured = i_piece
	
	return self
	
func promoted(type: Constants.PieceType) -> MoveRecord:
	
	promoted_to = type
	
	return self

func with_castled(i_piece: Piece) -> MoveRecord:
	castled = i_piece
	
	return self

func with_target(target: Piece) -> MoveRecord:
	
	if piece.is_on_same_team_as(target):
		if target.has_type(Constants.PieceType.Rook):
			return with_castled(target)
	else:
		return with_captured(target)
	
	return self

func resolve(chess_board: ChessBoard) -> void:
	if captured != null:
		await piece.attack_target(captured)
	if castled != null:
		
		var direction = (castled.grid_position - from).normalized()
		
		var king_grid_position = from + direction * 2
		var rook_grid_position = king_grid_position - direction
		
		var king_position = chess_board.get_canvas_position(king_grid_position)
		var rook_position = chess_board.get_canvas_position(rook_grid_position)
		
		await piece.move_to_position(king_position)
		await castled.move_to_position(rook_position)
		
		piece.grid_position = king_grid_position
		castled.grid_position = rook_grid_position
		
	else:
		var pos = chess_board.get_canvas_position(piece.grid_position)
	
		await piece.move_to_position(pos)

func undo() -> void:
	piece.grid_position = from
	
	if captured != null:
		captured.is_dead = false

func apply() -> void:
	
	piece.grid_position = to

	if captured != null:
		captured.is_dead = true
