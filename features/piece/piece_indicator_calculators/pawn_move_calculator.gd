class_name PawnMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> void:
	
	var pos = piece.get_board_position()
	
	var facing := piece.movement_controller.facing 
	
	var position_change: Vector2 = Vector2.LEFT if facing == GridController.Facing.Left else Vector2.RIGHT
	
	# the first square forward
	indicator_positions = [pos + position_change]
	
	# on the first move of a pawn, they can move 2 squares forward
	if is_first_move:
		indicator_positions.push_back(pos + position_change * 2)
	
	var top_target_pos = pos + position_change + Vector2.UP
	var bottom_target_pos = pos + position_change + Vector2.DOWN
	
	var top_target = piece.chess_board.opponent_party_at(top_target_pos)
	var bottom_target = piece.chess_board.opponent_party_at(bottom_target_pos)
	
	indicator_positions = indicator_positions\
		.filter(filter_blocked_positions)
	
	if top_target != null:
		indicator_positions.push_back(top_target_pos)
	
	if bottom_target != null:
		indicator_positions.push_back(bottom_target_pos)

func filter_blocked_positions(pos: Vector2) -> bool:
	
	if piece.chess_board.is_position_out_of_bounds(pos):
		return false
		
	if piece.chess_board.piece_exists_at(pos):
		return false
	
	return true
