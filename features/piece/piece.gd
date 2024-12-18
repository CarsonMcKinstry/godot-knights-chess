class_name Piece extends Area2D

@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var sprite: AnimatedSprite2D
@export var move_calculator: MoveCalculator

@export var start_position: Vector2
@export var intermediate_stop: Vector2

@export_category("Color Scheme")
@export var light_color: Color
@export var dark_color: Color

signal finished_entering

var is_ready: bool = false

func _ready():
	
	sprite.material.set_shader_parameter("light", light_color)
	sprite.material.set_shader_parameter("dark", dark_color)
	
	movement_controller.facing_changed.connect(handle_facing_change)
	
	if chess_board != null && move_calculator != null:
		move_calculator.chess_board = chess_board
	
	if chess_board != null:
		sprite.play("move")
		movement_controller.move_to(chess_board.get_absolute_position(intermediate_stop))
		await movement_controller.finished_moving
		movement_controller.move_to(chess_board.get_absolute_position(start_position))
		await movement_controller.finished_moving
		sprite.play("idle")
		is_ready = true
		finished_entering.emit()
	else:
		sprite.play("idle")
		
	

func handle_facing_change(facing: GridController.Facing):
	match facing:
		GridController.Facing.Left:
			sprite.flip_h = true
		GridController.Facing.Right:
			sprite.flip_h = false

func get_board_position():
	return chess_board.get_relative_position(position)
