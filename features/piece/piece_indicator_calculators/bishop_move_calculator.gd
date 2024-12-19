class_name BishopMoveCalculator extends MoveCalculator

func _calculate_indicator_positions():
	var pos = piece.get_board_position()
	
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.LEFT + Vector2.DOWN))
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.LEFT + Vector2.UP))
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.RIGHT + Vector2.DOWN))
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.RIGHT + Vector2.UP))
