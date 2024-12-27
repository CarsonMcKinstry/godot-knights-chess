class_name AttackController extends Node

@export var piece: Piece

var ATTACK_POSITION_OFFSET = Vector2.ZERO 

signal attack_collided
signal attack_finished

func attack(target: Piece) -> void:
	_attack(target)

func attack_en_passant(target: Piece) -> void:
	_attack_en_passant(target)

func _attack(target: Piece) -> void:
	pass
	
func _attack_en_passant(target: Piece) -> void:
	_attack(target)

func face_target(target: Piece) -> void:
	piece.movement_controller.face_toward(target.position)

func move_to_melee_attack_position(target: Piece) -> void:
	
	var target_position = target.grid_position
	
	if piece.grid_position.x < target_position.x:
		target_position += Vector2.LEFT
	elif piece.grid_position.x == target_position.x:
		if target.facing == Constants.Facing.Left:
			target_position += Vector2.LEFT
		else:
			target_position += Vector2.RIGHT
	else:
		target_position += Vector2.RIGHT
	
	var target_absolute_position = piece.chess_board.get_canvas_position(target_position)
	
	if piece.position.x < target.position.x:
		target_absolute_position += ATTACK_POSITION_OFFSET
	elif piece.position.x == target.position.x:
		if target.movement_controller.facing == Constants.Facing.Left:
			target_absolute_position += ATTACK_POSITION_OFFSET
		else:
			target_absolute_position -= ATTACK_POSITION_OFFSET
	else:
		target_absolute_position -= ATTACK_POSITION_OFFSET
		
	piece.movement_controller.move_to(target_absolute_position)
	await piece.movement_controller.finished_moving
