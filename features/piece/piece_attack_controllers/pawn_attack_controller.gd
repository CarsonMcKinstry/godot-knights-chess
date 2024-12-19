class_name PawnAttackController extends AttackController

func attack(target: Piece) -> void:
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
	await target.tree_exited
	piece.z_index = init_z_index
	
	piece.movement_controller.move_to(target_position)
	
	await piece.movement_controller.finished_moving
	
	attack_finished.emit()
	
func move_to_attack_position(target: Piece) -> void:
	
	var target_relative_position = piece.chess_board.get_relative_position(target.position)

	if piece.position.x < target.position.x:
		target_relative_position += Vector2.LEFT
	elif piece.position.x == target.position.x:
		if target.movement_controller.facing == GridController.Facing.Left:
			target_relative_position += Vector2.LEFT
		else:
			target_relative_position += Vector2.RIGHT
	else:
		target_relative_position += Vector2.RIGHT
	
	var target_absolute_position = piece.chess_board.get_absolute_position(target_relative_position)
	
	if piece.position.x < target.position.x:
		target_absolute_position += ATTACK_POSITION_OFFSET
	elif piece.position.x == target.position.x:
		if target.movement_controller.facing == GridController.Facing.Left:
			target_absolute_position += ATTACK_POSITION_OFFSET
		else:
			target_absolute_position -= ATTACK_POSITION_OFFSET
	else:
		target_absolute_position -= ATTACK_POSITION_OFFSET
	
	piece.move()
	piece.movement_controller.move_to(target_absolute_position)
	await piece.movement_controller.finished_moving
	piece.idle()
