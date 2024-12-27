class_name BishopMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> Array[Vector2]:
	var pos = piece.grid_position
	
	var possible_moves: Array[Vector2] = []
	
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.LEFT + Vector2.DOWN))
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.LEFT + Vector2.UP))
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.RIGHT + Vector2.DOWN))
	possible_moves.append_array(get_positions_in_direction(pos, Vector2.RIGHT + Vector2.UP))
	
	return possible_moves
