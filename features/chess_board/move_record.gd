class_name MoveRecord extends RefCounted

var side: Constants.Side

var from: Vector2
var to: Vector2

var piece: Piece

var captured: Piece
var promoted_to: Constants.PieceType

var castled: Piece

var original_rook_position: Vector2

var is_en_passant = false

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
	
	if piece.piece_type == Constants.PieceType.Pawn && piece.en_passant_possible(captured):
		is_en_passant = true
	
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
		var pos = chess_board.get_canvas_position(piece.grid_position)
		
		await piece.move_to_position(pos)
	if castled != null:
		var positions = calculate_castled_positions()
		
		var king_position = chess_board.get_canvas_position(positions[0])
		var rook_position = chess_board.get_canvas_position(positions[1])
		
		await piece.move_to_position(king_position)
		await castled.move_to_position(rook_position)
		
	else:
		var pos = chess_board.get_canvas_position(piece.grid_position)
	
		await piece.move_to_position(pos)

func undo() -> void:
	piece.grid_position = from
	
	if castled != null:
		
		castled.grid_position = original_rook_position
	
	if captured != null:
		captured.is_dead = false
		
		if is_en_passant:
			if piece.facing == Constants.Facing.Right:
				to += Vector2.LEFT
			else:
				to += Vector2.RIGHT
			piece.grid_position = to

func apply() -> void:

	piece.grid_position = to

	if castled != null:
		var positions = calculate_castled_positions()
		
		piece.grid_position = positions[0]
		
		original_rook_position = castled.grid_position
		
		castled.grid_position = positions[1]

	if captured != null:
		captured.is_dead = true
		
		if is_en_passant:
			if piece.facing == Constants.Facing.Right:
				to += Vector2.RIGHT
			else:
				to += Vector2.LEFT

			piece.grid_position = to

func calculate_castled_positions() -> Array[Vector2]:
	
	var direction = (castled.grid_position - from).normalized()
		
	var king_grid_position = from + direction * 2
	var rook_grid_position = king_grid_position - direction
	
	return [king_grid_position, rook_grid_position]
