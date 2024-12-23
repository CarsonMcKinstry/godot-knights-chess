class_name KingMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> Array[Vector2]:
	
	var pos = piece.get_board_position()
	
	var possible_moves: Array[Vector2] = []
	
	var position_changes: Array[Vector2] = [
		Vector2.UP,
		Vector2.UP + Vector2.RIGHT,
		Vector2.RIGHT,
		Vector2.DOWN + Vector2.RIGHT,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.LEFT + Vector2.DOWN,
		Vector2.LEFT + Vector2.UP
	]
	
	for position_change in position_changes:
		var next_position = pos + position_change
		
		if !is_blocked_position(next_position):
			possible_moves.push_back(next_position)
			
	return possible_moves


func is_blocked_position(pos: Vector2) -> bool:
	
	if piece.chess_board.is_position_out_of_bounds(pos):
		return true
		
	var target_piece = piece.chess_board.get_piece_at(pos)
	
	if target_piece != null && piece.is_on_same_team_as(target_piece):
		return true
	
	return false
