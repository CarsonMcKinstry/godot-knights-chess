class_name Piece extends Area2D



@export var piece_type: Constants.PieceType

@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var move_calculator: MoveCalculator
@export var animation_tree: AnimationTree
@export var sprites: Array[Sprite2D]
@export var attack_controller: AttackController
@export var party: PartyController

@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@export_category("Color Scheme")
@export var light_color: Color
@export var dark_color: Color

@onready var queen_template = preload("res://features/piece/pieces/queen.tscn")

signal finished_entering
signal finished_moving
signal finished_exiting

var is_ready: bool = true
var is_dead: bool = false
@onready var initial_facing: Constants.Facing = Constants.Facing.Right if party.side == Constants.Side.Player else Constants.Facing.Left
@onready var facing: Constants.Facing = initial_facing
var selected: bool = false

@onready var grid_position: Vector2 = chess_board.get_grid_position(position)

var capturable_by_en_passant: bool = false:
	set(next_state):
		
		if piece_type == Constants.PieceType.Pawn:
			capturable_by_en_passant = next_state
		else:
			capturable_by_en_passant = false

const animations = [
	"attack",
	"idle",
	"move",
	"death",
]

func _ready() -> void:
	if sprites.size() > 0:
		for sprite in sprites:
			sprite.material.set_shader_parameter("light", light_color)
			sprite.material.set_shader_parameter("dark", dark_color)
	
	movement_controller.facing_changed.connect(handle_facing_change)

	movement_controller.finished_moving.connect(handle_finish_moving)
	movement_controller.moving.connect(handle_moving)

	movement_controller.facing = initial_facing

func attack_hit():
	attack_controller.attack_collided.emit()

func handle_facing_change(i_facing: Constants.Facing) -> void:
	facing = i_facing

	match facing:
		Constants.Facing.Left:
			for animation in animations:
				animation_tree.set("parameters/%s/blend_position" % animation, -1.0)
		Constants.Facing.Right:
			for animation in animations:
				animation_tree.set("parameters/%s/blend_position" % animation, 1.0)

func select() -> bool:
	selected = true
	if move_calculator != null:
		move_calculator.show_indicators()
		
		if move_calculator.indicator_positions.size() == 0:
			return false
		return true
	else:
		return false
	

func deselect() -> void:
	selected = false
	if move_calculator != null:
		move_calculator.hide_indicators()

func damaged() -> void:
	animation_state.travel("death")

func died() -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"modulate:a",0.0,0.3)
	await tween.finished
	is_dead = true
	position = Vector2(1000, 1000)
	finished_exiting.emit()

func attack() -> void:
	animation_state.travel("attack")

func idle() -> void:
	animation_state.travel("idle")
	
func move() -> void:
	animation_state.travel("move")

func is_on_same_team_as(piece: Piece) -> bool:
	return party.contains(piece)

func handle_moving():
	move()
	
func handle_finish_moving():
	idle()

func attack_target(target: Piece) -> void:
	if piece_type == Constants.PieceType.Pawn && en_passant_possible(target):
		attack_controller.attack_en_passant(target)
	else:
		attack_controller.attack(target)
		
	await attack_controller.attack_finished
	
	movement_controller.face(initial_facing)
	
	if move_calculator != null:
		move_calculator.is_first_move = false

func move_to_position(pos: Vector2) -> void:
	
	if piece_type == Constants.PieceType.Pawn:
		var starting_pos = grid_position - chess_board.get_grid_position(position)
		if abs(starting_pos.x - pos.x) == 2:
			capturable_by_en_passant = true
	
	movement_controller.move_to(pos)
	await movement_controller.finished_moving
	
	movement_controller.face(initial_facing)
	
	if move_calculator != null:
		move_calculator.is_first_move = false
	

func en_passant_possible(target: Piece) -> bool:

	return target.capturable_by_en_passant

func get_all_possible_moves() -> Array[MoveRecord]:
	
	var moves: Array[MoveRecord] = []
	
	var move_positions = move_calculator._calculate_indicator_positions()
	
	for pos in move_positions:
		var move = MoveRecord.new(
			party.side,
			self,
			grid_position,
			pos
		)
		
		var target_piece = chess_board.get_piece_at(pos)
		
		if target_piece != null:
			if is_on_same_team_as(target_piece):
				if target_piece.piece_type == Constants.PieceType.Rook:
					move.with_castled(target_piece)
			else:
				move = move.with_captured(target_piece)
	
		moves.push_back(move)
	
	return moves

func has_type(type: Constants.PieceType) -> bool:
	return piece_type == type

func promote(promotion_type: Constants.PieceType):
	assert(piece_type == Constants.PieceType.Pawn)
	var queen: Piece = queen_template.instantiate()
	
	queen.chess_board = chess_board
	queen.party = party
	queen.position = position
	queen.grid_position = grid_position
	queen.initial_facing = initial_facing
	queen.facing = facing
	
	queen.light_color = light_color
	queen.dark_color = dark_color
	
	queen.modulate.a = 0.0

	party.add_child(queen)
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"modulate:a",0.0,0.3)
	tween.tween_property(queen, "modulate:a", 1.0, 0.3)
	await tween.finished

	queue_free()
