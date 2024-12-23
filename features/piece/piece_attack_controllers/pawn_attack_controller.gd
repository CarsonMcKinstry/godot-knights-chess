class_name PawnAttackController extends AttackController

func attack_en_passant(target: Piece) -> void:
	print("attacking en passant")
	ATTACK_POSITION_OFFSET = Vector2(8, 0)
	
	var init_z_index = piece.z_index
	var target_position = target.position
	
	await move_to_en_passant_position(target)
	
	piece.movement_controller.face_toward(target_position)
	piece.z_index = 1000
	# perform the attack
	piece.attack()
	
	await attack_collided
	# damage the target
	target.damaged()
	# emit signal
	await target.tree_exited
	piece.z_index = init_z_index
	
	piece.movement_controller.about_face()
	# something here is causing the dude to run off in to infinity
	if piece.movement_controller.facing == GridController.Facing.Left:
		piece.move_to(piece.position - ATTACK_POSITION_OFFSET)
	else:
		piece.move_to(piece.position + ATTACK_POSITION_OFFSET)
	
	await piece.movement_controller.finished_moving
	
	
	attack_finished.emit()

func attack(target: Piece) -> void:
	ATTACK_POSITION_OFFSET = Vector2(8, 0)
	var init_z_index = piece.z_index
	var target_position = target.position
	# move in front of the target
	await move_to_melee_attack_position(target)
	
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
	
	piece.movement_controller.move_to(target_absolute_position)
	await piece.movement_controller.finished_moving

func move_to_en_passant_position(target: Piece) -> Vector2:
	
	var target_relative_position = piece.chess_board.get_relative_position(target.position)

	# get direction target is facing...
	
	if piece.movement_controller.facing == GridController.Facing.Left:
		target_relative_position += Vector2.LEFT
	else:
		target_relative_position += Vector2.RIGHT
	
	var final_position = piece.chess_board.get_absolute_position(target_relative_position)
	
	var target_absolute_position = final_position
	
	if target.position.x < final_position.x:
		target_absolute_position -= ATTACK_POSITION_OFFSET
	else:
		target_absolute_position += ATTACK_POSITION_OFFSET
	
	piece.movement_controller.move_to(final_position)
	await piece.movement_controller.finished_moving
	
	return final_position
