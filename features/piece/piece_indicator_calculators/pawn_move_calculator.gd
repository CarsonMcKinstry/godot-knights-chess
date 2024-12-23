class_name PawnMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> Array[Vector2]:
	
	var pos = piece.get_board_position()
	
	var facing = piece.movement_controller.facing 
	
	var position_change: Vector2 = Vector2.LEFT if facing == GridController.Facing.Left else Vector2.RIGHT
	
	# the first 2 squares forward
	var possible_moves: Array[Vector2] = []
	
	possible_moves.append_array(get_forward_positions(pos, position_change))

	possible_moves.append_array(get_forward_attack_targets(pos, position_change))
	
	possible_moves.append_array(get_en_passant_moves(pos))
	
	possible_moves = possible_moves\
		.filter(func (pos): return !is_blocked_position(pos))

	return possible_moves

func is_blocked_position(pos: Vector2) -> bool:
	
	if piece.chess_board.is_position_out_of_bounds(pos):
		return true
		
	var target_piece = piece.chess_board.get_piece_at(pos)
	
	if target_piece != null && piece.is_on_same_team_as(target_piece):
		return true
	
	return false

func not_attackable(pos: Vector2) -> bool:
	var target = piece.chess_board.get_piece_at(pos)
	
	return target == null || piece.is_on_same_team_as(target)

func get_forward_positions(pos: Vector2, position_change: Vector2) -> Array[Vector2]:
	# the first 2 squares forward
	var possible_moves: Array[Vector2] = get_n_positions_in_direction(
		2 if is_first_move else 1,
		pos,
		position_change
	)
	
	var last_move = possible_moves.pop_back()
	
	if last_move != null:
		var target_piece = piece.chess_board.get_piece_at(last_move)
		
		if target_piece != null && piece.is_on_same_team_as(target_piece):
			possible_moves.push_back(last_move)
		elif target_piece == null:
			possible_moves.push_back(last_move)

	return possible_moves

func get_forward_attack_targets(pos: Vector2, position_change: Vector2) -> Array[Vector2]:
	
	var possible_moves: Array[Vector2] = []
	
	possible_moves.append_array(get_n_positions_in_direction(1, pos, position_change + Vector2.UP))
	possible_moves.append_array(get_n_positions_in_direction(1, pos, position_change + Vector2.DOWN))
	
	return possible_moves.filter(func (pos: Vector2) -> bool: return !not_attackable(pos))

func get_en_passant_moves(pos: Vector2) -> Array[Vector2]:
	var possible_moves: Array[Vector2] = []
	
	var top_position = pos + Vector2.UP
	var bottom_position = pos + Vector2.DOWN
	
	var top_target = piece.chess_board.get_piece_at(top_position)
	
	if top_target != null && top_target.capturable_by_en_passant:
		possible_moves.push_back(top_position)
	
	var bottom_target = piece.chess_board.get_piece_at(bottom_position)
	
	if bottom_target != null && bottom_target.capturable_by_en_passant:
		possible_moves.push_back(bottom_position)
	
	return possible_moves
