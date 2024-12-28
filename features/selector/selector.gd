class_name Selector extends Area2D

signal turn_finished

@export var sprite: AnimatedSprite2D
@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var player_party: PartyController
@export var opponent_party: PartyController

enum SelectorState {
	PieceSelect, # Choosing a piece to move
	PieceSelected, # Piece has been choosen
	TargetSelect,
	Idle, # Waiting for the piece to finish moving
}

var state: SelectorState = SelectorState.Idle

var hovered_piece: Piece = null
var selected_piece: Piece = null

var grid_position: Vector2

func _ready():
	movement_controller.finished_moving.connect(update_grid_position)
	update_grid_position()

func _physics_process(_delta: float) -> void:
	
	if state == SelectorState.Idle:
		self.hide()
	else:
		self.show()
	#
	match state:
		SelectorState.PieceSelect:
			sprite.play("default")
			handle_move()
			handle_select()
		SelectorState.PieceSelected:
			sprite.play("hovering_piece")
			handle_move()
			handle_target_select()
			
func handle_move() -> void:
	var direction = movement_controller.get_movement_direction()
	
	if direction != Vector2.ZERO:
		if chess_board != null:
			if !chess_board.is_direction_out_of_bounds(position, direction):
				movement_controller.move_in(direction)
				await movement_controller.finished_moving
		else:
			movement_controller.move_in(direction)
			await movement_controller.finished_moving

func update_grid_position():
	grid_position = chess_board.get_grid_position(position)

func handle_select() -> void:
	if Input.is_action_just_pressed("ui_select"):
		
		var pos = chess_board.get_grid_position(position)
		
		var piece = chess_board.get_piece_at(pos)
		
		if piece != null && piece.party.side == Constants.Side.Player:
			piece.select()
			selected_piece = piece
			state = SelectorState.PieceSelected

func handle_target_select() -> void:
	if Input.is_action_just_pressed("ui_select"):
		
		var pos = chess_board.get_grid_position(position)
	
		if can_piece_move_there(pos):
			
			var move = MoveRecord.new(
				Constants.Side.Player,
				selected_piece,
				selected_piece.grid_position,
				pos
			)
			
			var target_piece = chess_board.get_piece_at(pos)
			
			if target_piece != null:
				print(target_piece.is_dead)
				move = move.with_target(target_piece)

			var is_valid_move = chess_board.validate_move(move)

			if is_valid_move:
				
				chess_board.enqueue_move(move)
			
				state = SelectorState.Idle
				selected_piece.deselect()
				selected_piece = null
				
				await chess_board.resolve_latest_move()
				turn_finished.emit()
			else:
				print("Move would leave king in check")

	elif Input.is_action_just_pressed("ui_cancel"):
		selected_piece.deselect()
		state = SelectorState.PieceSelect
		selected_piece = null

func attack_target(target: Piece) -> void:
	selected_piece.deselect()
	state = SelectorState.Idle
	await selected_piece.attack_target(target)
	selected_piece = null
	turn_finished.emit()

func move_piece_to_position(pos: Vector2) -> void:
	selected_piece.deselect()
	state = SelectorState.Idle
	await selected_piece.move_to_position(pos)
	selected_piece = null
	turn_finished.emit()

func castle_the_king(target_piece: Piece) -> void:
	selected_piece.deselect()
	state = SelectorState.Idle
	var next_position = Vector2.ZERO
	var target_position = Vector2.ZERO
	if selected_piece.get_board_position().y > target_piece.get_board_position().y:
		next_position = selected_piece.get_board_position() - Vector2(0, 2)
		target_position = next_position + Vector2(0, 1)
	else:
		next_position = selected_piece.get_board_position() + Vector2(0, 2)
		target_position = next_position - Vector2(0, 1)
	await target_piece.move_to_position(target_position)
	await selected_piece.move_to_position(next_position)
	selected_piece = null
	turn_finished.emit()

func can_piece_move_there(position: Vector2) -> bool:
	
	return selected_piece.move_calculator != null && selected_piece.move_calculator.indicator_positions.has(position)

func should_castle_a_king(target_piece: Piece) -> bool:
	
	var is_selected_king = selected_piece.piece_type == Constants.PieceType.King
	var is_target_rook = target_piece.piece_type == Constants.PieceType.Rook
	
	var pieces_havent_moved = selected_piece.move_calculator.is_first_move && target_piece.move_calculator.is_first_move
	
	return is_selected_king && is_target_rook && pieces_havent_moved

func start_turn() -> void:
	state = SelectorState.PieceSelect


func _on_area_entered(piece: Piece) -> void:
	# use this later for UI?
	hovered_piece = piece


func _on_area_exited(piece: Piece) -> void:
	# same here?
	hovered_piece = null
