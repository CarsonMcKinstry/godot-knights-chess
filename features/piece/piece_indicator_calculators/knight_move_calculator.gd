class_name KnightMoveCalculator extends MoveCalculator

const UP_BASE: Vector2 = Vector2.UP * 2;
const LEFT_BASE: Vector2 = Vector2.LEFT * 2;
const DOWN_BASE: Vector2 = Vector2.DOWN * 2;
const RIGHT_BASE: Vector2 = Vector2.RIGHT * 2;

func _calculate_indicator_positions() -> void:
	
	var pos = piece.get_board_position()

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

		indicator_positions.push_back(pos + position_change)

	indicator_positions = indicator_positions\
		.filter(filter_blocked_positions)

func filter_blocked_positions(pos: Vector2):
	
	if piece.chess_board.is_position_out_of_bounds(pos):
		return false
	
	var piece_at_pos = piece.chess_board.get_piece_at(pos)
	
	if piece.is_on_same_team_as(piece_at_pos):
		return false

	return true
