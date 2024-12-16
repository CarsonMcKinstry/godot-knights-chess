class_name ChessBoard extends Area2D

@export var grid_line: Line2D
@export var grid_lines: Node2D

const UPPER_BOUND = 8
const LOWER_BOUND = 1
const LEFT_BOUND = 1
const RIGHT_BOUND = 8

const RELATIVE_OFFSET: Vector2 = Vector2(-16, -16)
const POSITION_CORRECTION: Vector2 = Vector2(5, 5)

func get_relative_position(pos: Vector2) -> Vector2:
	return ((pos + RELATIVE_OFFSET) / 32) + POSITION_CORRECTION

func get_absolute_position(pos: Vector2) -> Vector2:
	return ((pos - POSITION_CORRECTION) * 32) - RELATIVE_OFFSET

func is_direction_out_of_bounds(pos: Vector2, direction: Vector2) -> bool:
	
	var relative_position = get_relative_position(pos)
	
	match direction:
		Vector2.UP:
			return relative_position.y == LOWER_BOUND
		Vector2.RIGHT:
			return relative_position.x == RIGHT_BOUND
		Vector2.DOWN:
			return relative_position.y == UPPER_BOUND
		Vector2.LEFT:
			return relative_position.x == LEFT_BOUND

	return false

func _ready():
	
	for y in range(0, 9):
		var line = grid_line.duplicate()
		for x in range(0, 9):
			line.add_point(Vector2(-128 + x * 32, -128 + y * 32))
		grid_lines.add_child(line)

	for x in range(0, 9):
		var line = grid_line.duplicate()
		for y in range(0, 9):
			line.add_point(Vector2(-128 + x * 32, -128 + y * 32))
		grid_lines.add_child(line)
