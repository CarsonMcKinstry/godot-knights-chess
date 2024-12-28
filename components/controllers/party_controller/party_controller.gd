class_name PartyController extends Node2D

@export var side: Constants.Side

func is_ready():
	for child in get_children():
		if !child.is_ready:
			return false
	return true

func contains(piece: Piece):
	return get_children().has(piece)

func get_piece_at(pos: Vector2) -> Piece:
	for child in get_children():
		if child.position == pos:
			return child
	return null

func get_pieces() -> Array[Piece]:
	
	var pieces: Array[Piece] = []
	
	for child in get_children():
		if child is Piece:
			pieces.push_back(child)
	
	return pieces.filter(func (piece: Piece): return !piece.is_dead)

func get_attackable_positions() -> Array[Vector2]:
	var attackable_positions: Array[Vector2]
	
	for piece in get_pieces():
		for pos in piece.get_all_possible_moves():
			if !attackable_positions.has(pos):
				attackable_positions.push_back(pos)

	return attackable_positions
		
