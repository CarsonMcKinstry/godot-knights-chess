class_name RookMoveCalculator extends MoveCalculator

func _calculate_indicator_positions():
	var pos = piece.get_board_position()
	
	var facing = piece.movement_controller.facing 
	
	var position_change: Vector2 = Vector2.LEFT if facing == GridController.Facing.Left else Vector2.RIGHT
	
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.LEFT))
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.RIGHT))
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.UP))
	indicator_positions.append_array(get_positions_in_direction(pos, Vector2.DOWN))
