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

@export var start_position: Vector2

@export_category("Color Scheme")
@export var light_color: Color
@export var dark_color: Color

signal finished_entering
signal finished_moving

var is_ready: bool = false
@onready var initial_facing: Constants.Facing = Constants.Facing.Right if party.side == Constants.Side.Player else Constants.Facing.Left
@onready var facing: Constants.Facing = initial_facing
var selected: bool = false

@onready var grid_position: Vector2 = start_position

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
	#
	movement_controller.facing_changed.connect(handle_facing_change)
	#
	movement_controller.finished_moving.connect(handle_finish_moving)
	movement_controller.moving.connect(handle_moving)
	#
	handle_facing_change(initial_facing)

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

func get_board_position() -> Vector2:
	return chess_board.get_relative_position(position)

func select() -> void:
	selected = true
	if move_calculator != null:
		move_calculator.show_indicators()

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
	queue_free()

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
	
	if move_calculator != null:
		move_calculator.is_first_move = false

func move_to_position(pos: Vector2) -> void:
	
	if piece_type == Constants.PieceType.Pawn:
		var starting_pos = grid_position - chess_board.get_grid_position(position)
		if abs(starting_pos.x - pos.x) == 2:
			capturable_by_en_passant = true
	
	movement_controller.move_to(pos)
	await movement_controller.finished_moving
	
	if move_calculator != null:
		move_calculator.is_first_move = false
	
	#
	#chess_board.record_move(
		#self,
		#get_board_position(),
		#pos,
		#party.side
	#)
	#
	#movement_controller.move_to(chess_board.get_absolute_position(pos))
	#await movement_controller.finished_moving
	#if move_calculator != null:
		#move_calculator.is_first_move = false

func en_passant_possible(target: Piece) -> bool:
	return \
		target.grid_position.x == grid_position.x\
		&& target.capturable_by_en_passant
