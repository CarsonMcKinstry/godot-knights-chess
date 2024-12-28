class_name KingMoveCalculator extends MoveCalculator

func _calculate_indicator_positions() -> Array[Vector2]:
	
	var pos = piece.grid_position
	
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
	
	possible_moves.append_array(get_castling_positions())
	
	return possible_moves


func is_blocked_position(pos: Vector2) -> bool:
	
	if chess_board.is_position_out_of_bounds(pos):
		return true
	
	if is_position_under_attack(pos):
		return true
	
	var target_piece = chess_board.get_piece_at(pos)
	
	if target_piece != null && piece.is_on_same_team_as(target_piece):
		return true
	
	return false

func get_castling_positions() -> Array[Vector2]:

	if !is_first_move || is_under_attack():
		return []
	
	var moves: Array[Vector2] = []
	
	var rooks = chess_board.get_pieces_of_type(Constants.PieceType.Rook, piece.party.side)
	
	for rook in rooks:
		if rook.move_calculator.is_first_move:
	
			var direction = (rook.grid_position - piece.grid_position).normalized()

			var open_positions = range(0, 2)\
				.filter(func (d: int): return !is_blocked_position(
					piece.grid_position + direction * (d + 1)
				))
		
			if open_positions.size() == 2:
				moves.push_back(rook.grid_position)
	
	return moves
