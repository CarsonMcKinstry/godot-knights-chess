class_name PieceConfig extends Resource

@export var opening_grid_path: Array[Vector2]

@export var piece_template: PackedScene

func setup(
	party_controller: PartyController,
	chess_board: ChessBoard,
	color: Color,
	shadow_color: Color
):
	var piece: Piece = piece_template.instantiate()
	
	piece.grid_position = opening_grid_path.front()
	piece.position = chess_board.get_canvas_position(opening_grid_path.front())
	piece.light_color = color
	piece.dark_color = shadow_color
	piece.party = party_controller
	piece.chess_board = chess_board
	
	party_controller.add_child(piece)
	
	await _walk_opening_path(piece, opening_grid_path.slice(1))
	
	piece.is_ready = true
	piece.grid_position = opening_grid_path.back()

func _walk_opening_path(piece: Piece, path: Array[Vector2]) -> void:
	for point in path:
		await piece.move_to_grid_position(point)
