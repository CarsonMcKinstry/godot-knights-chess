class_name KnightMoveCalculator extends MoveCalculator

const UP_BASE: Vector2 = Vector2.UP * 2;
const LEFT_BASE: Vector2 = Vector2.LEFT * 2;
const DOWN_BASE: Vector2 = Vector2.DOWN * 2;
const RIGHT_BASE: Vector2 = Vector2.RIGHT * 2;

func _calculate_indicator_positions() -> Array[Vector2]:
	
	var pos = piece.grid_position

	var possible_moves: Array[Vector2] = []

	var position_changes = [
		UP_BASE + Vector2.LEFT,
		UP_BASE + Vector2.RIGHT,
		RIGHT_BASE + Vector2.UP,
		RIGHT_BASE + Vector2.DOWN,
		DOWN_BASE + Vector2.LEFT,
		DOWN_BASE + Vector2.RIGHT,
		LEFT_BASE + Vector2.UP,
		LEFT_BASE + Vector2.DOWN,
	]
	
	for position_change in position_changes:
		var possible_move = pos + position_change
		if !is_position_blocked(possible_move):
			possible_moves.push_back(possible_move)
		
	return possible_moves

func is_position_blocked(pos: Vector2) -> bool:

	if piece.chess_board.is_position_out_of_bounds(pos):
		return true
		
	var piece_at_pos = piece.chess_board.get_piece_at(pos)
	
	if piece.is_on_same_team_as(piece_at_pos):
		return true
	
	return false
