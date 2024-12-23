class_name PawnMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> Array[Vector2]:
	
	var pos = piece.get_board_position()
	
	var facing = piece.movement_controller.facing 
	
	var position_change: Vector2 = Vector2.LEFT if facing == GridController.Facing.Left else Vector2.RIGHT
	
	# the first square forward
	var possible_moves: Array[Vector2] = [pos + position_change]
	
	if piece.chess_board.piece_exists_at(possible_moves[0]):
		return []
	
	# on the first move of a pawn, they can move 2 squares forward
	if is_first_move:
		possible_moves.push_back(pos + position_change * 2)
	
	var top_target_pos = pos + position_change + Vector2.UP
	var bottom_target_pos = pos + position_change + Vector2.DOWN
	
	var top_target = piece.chess_board.get_piece_at(top_target_pos)
	var bottom_target = piece.chess_board.get_piece_at(bottom_target_pos)
	
	possible_moves = possible_moves\
		.filter(filter_blocked_positions)
	
	if top_target != null && !piece.is_on_same_team_as(top_target):
		possible_moves.push_back(top_target_pos)
	
	if bottom_target != null && !piece.is_on_same_team_as(bottom_target):
		possible_moves.push_back(bottom_target_pos)
		
	return possible_moves

func filter_blocked_positions(pos: Vector2) -> bool:
	
	if piece.chess_board.is_position_out_of_bounds(pos):
		return false
		
	if piece.chess_board.piece_exists_at(pos):
		return false
	
	return true
