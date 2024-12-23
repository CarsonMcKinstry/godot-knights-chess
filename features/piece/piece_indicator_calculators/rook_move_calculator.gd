class_name RookMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> Array[Vector2]:
	var pos = piece.get_board_position()
	
	var possible_moves: Array[Vector2] = []
	
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.LEFT))
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.RIGHT))
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.UP))
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.DOWN))

	return possible_moves
