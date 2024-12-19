class_name PartyController extends Node2D

func is_ready():
	for child in get_children():
		if !child.is_ready:
			return false
	return true

func contains(piece: Piece):
	return get_children().has(piece)

func get_piece_at(pos: Vector2):
	return get_children()\
		.filter(func (child: Piece): return child.position == pos)\
		.front()
