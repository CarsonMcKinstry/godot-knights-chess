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
	
func do_piece_updates():
	for move in resolved_moves:
		move.piece.grid_position = move.to

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		var piece = get_piece_at(Vector2(1, 1))
		var target_piece = get_piece_at(Vector2(6, 1))
		var move = MoveRecord.new(
			Constants.Side.Player,
			piece,
			piece.grid_position,
			Vector2(3, 1)
		).with_captured(target_piece)
		
		enqueue_move(move)
		do_piece_updates()
		
		resolve_latest_move()
	
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

#func get_relative_position(pos: Vector2) -> Vector2:
	#return ((pos + RELATIVE_OFFSET) / 32) + POSITION_CORRECTION
#
#func get_absolute_position(pos: Vector2) -> Vector2:
	#return ((pos - POSITION_CORRECTION) * 32) - RELATIVE_OFFSET
#
#func is_direction_out_of_bounds(pos: Vector2, direction: Vector2) -> bool:
	#
	#var relative_position = get_relative_position(pos)
	#
	#match direction:
		#Vector2.UP:
			#return relative_position.y == LOWER_BOUND
		#Vector2.RIGHT:
			#return relative_position.x == RIGHT_BOUND
		#Vector2.DOWN:
			#return relative_position.y == UPPER_BOUND
		#Vector2.LEFT:
			#return relative_position.x == LEFT_BOUND
#
	#return false
#
#func is_position_out_of_bounds(pos: Vector2) -> bool:
	#var oob_left = pos.x < LEFT_BOUND
	#var oob_right = pos.x > RIGHT_BOUND
	#var oob_top = pos.y < LOWER_BOUND
	#var oob_down = pos.y > UPPER_BOUND
	#
	#return oob_down || oob_left || oob_right || oob_top
#

#
#func player_party_contains(piece: Piece) -> bool:
	#return player_party.contains(piece)
#
#func opponent_party_contains(piece: Piece) -> bool:
	#return opponent_party.contains(piece)
#
#func piece_exists_at(pos: Vector2) -> bool:
	#return get_player_piece_at(pos) != null || get_opponent_piece_at(pos) != null
#
#func has_player_piece_at(pos: Vector2):
	#return get_player_piece_at(pos) != null
#
#func has_opponent_piece_at(pos: Vector2):
	#return get_opponent_piece_at(pos) != null
#
#func get_piece_at(pos: Vector2) -> Piece:
	#var player_piece = get_player_piece_at(pos)
	#if player_piece != null:
		#return player_piece
		#
	#var opponent_piece = get_opponent_piece_at(pos)
	#if opponent_piece != null:
		#return opponent_piece
	#
	#return null
#
#func get_player_piece_at(pos: Vector2) -> Piece:
	#var abs_pos = get_absolute_position(pos)
	#return player_party.get_piece_at(abs_pos)
#
#func get_opponent_piece_at(pos: Vector2) -> Piece:
	#var abs_pos = get_absolute_position(pos)
	#return opponent_party.get_piece_at(abs_pos)
#
#func record_move(
	#piece: Piece,
	#from: Vector2,
	#to: Vector2,
	#side: Constants.Side
#):
	#moves.push_front(
		#MoveRecord.new(
			#piece,
			#side,
			#from,
			#to
		#)
	#)
	#
#func record_capture(
	#piece: Piece,
	#from: Vector2,
	#to: Vector2,
	#side: Constants.Side,
	#target: Piece
#):
	#moves.push_front(
		#MoveRecord.with_capture(
			#piece,
			#side,
			#from,
			#to,
			#target
		#)
	#)
