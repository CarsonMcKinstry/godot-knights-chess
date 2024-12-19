class_name Piece extends Area2D

@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var move_calculator: MoveCalculator
@export var animation_tree: AnimationTree
@export var sprites: Array[Sprite2D]
@export var attack_controller: AttackController

@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@export var start_position: Vector2
@export var intermediate_stop: Vector2

@export_category("Color Scheme")
@export var light_color: Color
@export var dark_color: Color

signal finished_entering


var is_ready: bool = false

var selected: bool = false

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
	
	handle_facing_change(movement_controller.facing)
	
	if chess_board != null:
		animation_state.travel("move")
		movement_controller.move_to(chess_board.get_absolute_position(intermediate_stop))
		await movement_controller.finished_moving
		movement_controller.move_to(chess_board.get_absolute_position(start_position))
		await movement_controller.finished_moving
		animation_state.travel("idle")
		is_ready = true
		finished_entering.emit()
	else:
		animation_state.travel("idle")
		is_ready = true
		finished_entering.emit()

func attack_hit():
	attack_controller.attack_collided.emit()

func handle_facing_change(facing: GridController.Facing) -> void:
	match facing:
		GridController.Facing.Left:
			for animation in animations:
				animation_tree.set("parameters/%s/blend_position" % animation, -1.0)
		GridController.Facing.Right:
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
