class_name RookAttackController extends AttackController



func _attack(target: Piece) -> void:
	ATTACK_POSITION_OFFSET = Vector2(8, 0)
	var init_z_index = piece.z_index
	var target_position = target.position
	# move in front of the target
	move_to_melee_attack_position(target)
	await piece.movement_controller.finished_moving
	
	piece.movement_controller.face_toward(target_position)
	piece.z_index = 1000
	# perform the attack
	piece.attack()
	# wait for the attack collide signal
	await attack_collided
	# damage the target
	target.damaged()
	# emit signal
	await target.finished_exiting
	piece.z_index = init_z_index
	
	piece.movement_controller.move_to(target_position)
	
	await piece.movement_controller.finished_moving
	
	attack_finished.emit()
