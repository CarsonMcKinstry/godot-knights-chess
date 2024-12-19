class_name RookAttackController extends AttackController

const ATTACK_POSITION_OFFSET: Vector2 = Vector2(8, 0)

func attack(target: Piece) -> void:
	var target_position = target.position
	# move in front of the target
	move_to_attack_position(target)
	await piece.movement_controller.finished_moving
	
	piece.movement_controller.face_toward(target_position)
	# perform the attack
	piece.attack()
	# wait for the attack collide signal
	await attack_collided
	# damage the target
	target.damaged()
	# emit signal
	await target.tree_exited
	
	piece.movement_controller.move_to(target_position)
	
	await piece.movement_controller.finished_moving
	
	attack_finished.emit()
	
func move_to_attack_position(target: Piece) -> void:
	
	var target_relative_position = piece.chess_board.get_relative_position(target.position)

	if piece.position.x < target.position.x:
		target_relative_position += Vector2.LEFT
	else:
		target_relative_position += Vector2.RIGHT
	
	var target_absolute_position = piece.chess_board.get_absolute_position(target_relative_position)
	
	if piece.position.x < target.position.x:
		target_absolute_position += ATTACK_POSITION_OFFSET
	else:
		target_absolute_position -= ATTACK_POSITION_OFFSET
	
	piece.movement_controller.move_to(target_absolute_position)
