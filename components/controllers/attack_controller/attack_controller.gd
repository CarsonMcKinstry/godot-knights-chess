class_name AttackController extends Node

@export var piece: Piece

signal attack_collided
signal attack_finished

func attack(target: Piece) -> void:
	pass
	
func face_target(target: Piece) -> void:
	piece.movement_controller.face_toward(target.position)
