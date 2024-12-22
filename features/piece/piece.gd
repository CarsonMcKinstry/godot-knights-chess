class_name Piece extends Area2D

enum PieceType {
	Pawn,
	Rook,
	Knight,
	Bishop,
	King,
	Queen
}

@export var piece_type: PieceType

@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var move_calculator: MoveCalculator
@export var animation_tree: AnimationTree
@export var sprites: Array[Sprite2D]
@export var attack_controller: AttackController
@export var party: PartyController

@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@export var start_position: Vector2
@export var intermediate_stop: Vector2

@export_category("Color Scheme")
@export var light_color: Color
@export var dark_color: Color

signal finished_entering
signal finished_moving

var is_ready: bool = false
var initial_facing: GridController.Facing
var facing: GridController.Facing
var selected: bool = false

var grid_position: Vector2 = Vector2.ZERO

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
	
	handle_facing_change(movement_controller.facing)
	
	if chess_board != null:
		movement_controller.move_to(chess_board.get_absolute_position(intermediate_stop))
		await movement_controller.finished_moving
		movement_controller.move_to(chess_board.get_absolute_position(start_position))
		await movement_controller.finished_moving
		is_ready = true
		finished_entering.emit()
	else:
		is_ready = true
		finished_entering.emit()
		
	

func attack_hit():
	attack_controller.attack_collided.emit()

func handle_facing_change(i_facing: GridController.Facing) -> void:
	facing = i_facing
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

func is_on_same_team_as(piece: Piece) -> bool:
	return party.contains(piece)

func handle_moving():
	move()
	
func handle_finish_moving():
	idle()

func get_all_possible_moves() -> Array[Vector2]:
	move_calculator._calculate_indicator_positions()
	return move_calculator.indicator_positions

func move_to(pos: Vector2) -> void:
	var target_piece = chess_board.get_piece_at(pos)
	
	if target_piece != null:
		if !is_on_same_team_as(target_piece):
			await attack_target(target_piece)
	else:
		await move_to_position(pos)
		
	finished_moving.emit()

func attack_target(target: Piece) -> void:
	attack_controller.attack(target)
	await attack_controller.attack_finished
	
	if move_calculator != null:
		move_calculator.is_first_move = false

func move_to_position(pos: Vector2) -> void:
	movement_controller.move_to(chess_board.get_absolute_position(pos))
	await movement_controller.finished_moving
	if move_calculator != null:
		move_calculator.is_first_move = false

#var target_piece = chess_board.get_piece_at(relative_position)
			#
			#if target_piece != null:
				#if player_party.contains(target_piece):
					#pass
				#elif opponent_party.contains(target_piece):
					#await attack_target(target_piece)
			#else:
				#await move_piece_to_position(relative_position)

#func attack_target(target: Piece) -> void:
	#selected_piece.deselect()
	#state = SelectorState.Idle
	#selected_piece.attack_controller.attack(target)
	#await selected_piece.attack_controller.attack_finished
	#if selected_piece.move_calculator != null:
		#selected_piece.move_calculator.is_first_move = false
	#selected_piece = null
	#turn_finished.emit()
#
#func move_piece_to_position(pos: Vector2) -> void:
	#selected_piece.move()
	#selected_piece.movement_controller.move_to(chess_board.get_absolute_position(pos))
	#selected_piece.deselect()
	#state = SelectorState.Idle
	#await selected_piece.movement_controller.finished_moving
	#if selected_piece.move_calculator != null:
		#selected_piece.move_calculator.is_first_move = false
	#selected_piece.idle()
	#selected_piece = null
	#turn_finished.emit()
