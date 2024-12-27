class_name ChessBoard extends Area2D

@export var grid_line: Line2D
@export var grid_lines: Node2D

@export var player_party: PartyController
@export var computer_party: PartyController

const UPPER_BOUND = 7
const LOWER_BOUND = 0
const LEFT_BOUND = 0
const RIGHT_BOUND = 7

const RELATIVE_OFFSET: Vector2 = Vector2(-16, -16)
const POSITION_CORRECTION: Vector2 = Vector2(5, 5)
const GRID_OFFSET = Vector2(128, 128)

var moves: Array[MoveRecord] = []

var resolved_moves: Array[MoveRecord] = []

func _ready() -> void:
	
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

func enqueue_move(move: MoveRecord): 
	resolved_moves.push_front(move)
	apply_piece_updates()

func undo():
	while !resolved_moves.is_empty():
		var move: MoveRecord = resolved_moves.pop_front()
		move.undo()

func apply_piece_updates():
	for move in resolved_moves:
		move.apply()

func resolve_latest_move():
	assert(!resolved_moves.is_empty(), "can't resolve no moves")
	
	var move = resolved_moves.pop_back()

	await move.resolve(self)
	
	moves.push_front(move)

func pieces() -> Array[Piece]:
	return player_party.get_pieces() + computer_party.get_pieces()

func get_grid_position(canvas_pos: Vector2) -> Vector2:
	return ((canvas_pos + RELATIVE_OFFSET) / 32 ) + POSITION_CORRECTION - Vector2.ONE

func get_canvas_position(grid_pos: Vector2) -> Vector2:
	
	return (grid_pos * 32) - RELATIVE_OFFSET - GRID_OFFSET
	
func get_piece_at(grid_pos: Vector2) -> Piece:
	for piece in pieces():
		if piece.grid_position == grid_pos:
			return piece
	return null

func is_direction_out_of_bounds(pos: Vector2, direction: Vector2) -> bool:
	
	var relative_position = get_grid_position(pos)
	
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

func is_position_out_of_bounds(grid_position: Vector2) -> bool:
	return grid_position.x < LEFT_BOUND || grid_position.x > RIGHT_BOUND || grid_position.y < LOWER_BOUND || grid_position.y > UPPER_BOUND
