class_name KnightAttackController extends AttackController

func _attack(target: Piece) -> void:
	var init_z_index = piece.z_index
	var target_position = target.position
	# move in front of the target
	move_to_attack_position(target)
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
	
func move_to_attack_position(target: Piece) -> void:
	var target_position = target.grid_position

	if piece.grid_position.x < target.grid_position.x:
		target_position += Vector2.RIGHT
	else:
		target_position += Vector2.LEFT
	
	var target_absolute_position = piece.chess_board.get_canvas_position(target_position)
	
	piece.movement_controller.move_to(target_absolute_position)
	await piece.movement_controller.finished_moving
