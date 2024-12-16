class_name Piece extends Area2D

@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var sprite: AnimatedSprite2D

@export var start_position: Vector2
@export var intermediate_stop: Vector2

var is_ready: bool = false

func _ready():
	
	movement_controller.facing_changed.connect(handle_facing_change)
	
	if chess_board != null:
		sprite.play("move")
		movement_controller.move_to(chess_board.get_absolute_position(intermediate_stop))
		await movement_controller.finished_moving
		movement_controller.move_to(chess_board.get_absolute_position(start_position))
		await movement_controller.finished_moving
		sprite.play("idle")
		is_ready = true
	else:
		sprite.play("idle")
		
	

func handle_facing_change(facing: GridController.Facing):
	match facing:
		GridController.Facing.Left:
			sprite.flip_h = true
		GridController.Facing.Right:
			sprite.flip_h = false
