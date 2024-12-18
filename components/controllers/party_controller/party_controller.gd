class_name PartyController extends Node2D

func is_ready():
	return get_children().all(func(child: Piece): return child.is_ready)

func contains(piece: Piece):
	return get_children().has(piece)
