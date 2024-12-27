class_name PawnAttackController extends AttackController

func _attack_en_passant(target: Piece) -> void:
	ATTACK_POSITION_OFFSET = Vector2(8, 0)
	
	var init_z_index = piece.z_index
	var target_position = target.position
	
	var final_position = await move_to_en_passant_position(target)

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

	match piece.movement_controller.facing:
		Constants.Facing.Left:
			piece.movement_controller.move_to(target_position + Vector2.LEFT * 32)
		Constants.Facing.Right:
			piece.movement_controller.move_to(target_position + Vector2.RIGHT * 32)
	
	await piece.movement_controller.finished_moving
	
	attack_finished.emit()

func _attack(target: Piece) -> void:

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
	
func move_to_en_passant_position(target: Piece) -> Vector2:
	
	var target_relative_position = piece.chess_board.get_relative_position(target.position)
	
	if piece.movement_controller.facing == Constants.Facing.Left:
		target_relative_position += Vector2.LEFT
	else:
		target_relative_position += Vector2.RIGHT
	
	var final_position = piece.chess_board.get_absolute_position(target_relative_position)
	
	var target_absolute_position = final_position
	
	if target.position.x < final_position.x:
		target_absolute_position -= ATTACK_POSITION_OFFSET
	else:
		target_absolute_position += ATTACK_POSITION_OFFSET
	
	piece.movement_controller.move_to(target_absolute_position)
	await piece.movement_controller.finished_moving
	
	return final_position
