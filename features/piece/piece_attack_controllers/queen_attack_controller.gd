class_name QueenAttackController extends AttackController

@onready var smite_temp = preload("res://components/spell_effects/smite/smite.tscn")

func _attack(target: Piece) -> void:
	var target_position = target.position
	
	var smite: Smite = smite_temp.instantiate()
	
	smite.position = target_position + piece.chess_board.position
	
	piece.movement_controller.face_toward(target_position)
	
	piece.attack()
	
	add_child(smite)
	
	await smite.hit_collided
	
	target.damaged()
	
	await target.tree_exited
	
	smite.queue_free()
	
	piece.movement_controller.move_to(target_position)
	
	await piece.movement_controller.finished_moving
	
	attack_finished.emit()
