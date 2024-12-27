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
	
	var pieces_under_attack = piece.chess_board.opponent_party.get_attackable_positions() if piece.selected else []
	
	for position_change in position_changes:
		var next_position = pos + position_change
		
		if !is_blocked_position(next_position):
			possible_moves.push_back(next_position)

	if piece.selected:
		possible_moves.append_array(get_castling_positions(pieces_under_attack))

	return possible_moves.filter(func (move): return !pieces_under_attack.has(move))


func is_blocked_position(pos: Vector2) -> bool:
	
	if piece.chess_board.is_position_out_of_bounds(pos):
		return true
		
	var target_piece = piece.chess_board.get_piece_at(pos)
	
	if target_piece != null && piece.is_on_same_team_as(target_piece):
		return true
	
	return false

func get_castling_positions(positions_under_attack: Array[Vector2]) -> Array[Vector2]:
	
	if !is_first_move:
		return []
	
	var pos = piece.get_board_position()
	var rooks: Array[Piece] = piece.party.get_pieces()\
		.filter(func (p: Piece): return p.piece_type == Constants.PieceType.Rook && is_first_move)
	
	# okay, we have our rooks
	
	# grab all the positions under attack
	
	# check if the king is under attack
	if positions_under_attack.has(pos):
		return []
		
	var castling_positions: Array[Vector2] = []

	for rook in rooks:
		var rook_board_position = rook.get_board_position()		
		
		var positions_which_should_be_clear: Array[Vector2] = []	
		
		var can_castle = true
		
		for i in range(1, abs(rook_board_position.y - pos.y)):
			var position = Vector2.ZERO
			if rook_board_position.y < pos.y:
				position = pos - Vector2(0, i)
			else:
				position = pos + Vector2(0, i)
				
			if i < 3 && positions_under_attack.has(position):
				print("position under attack... can't move there")
				can_castle = false
				break
				
			if piece.chess_board.piece_exists_at(position):
				print("position occupied")
				can_castle = false
				break

		if can_castle:
			castling_positions.push_back(rook_board_position)

	return castling_positions
