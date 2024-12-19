class_name Selector extends Area2D

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

func handle_select() -> void:
	if Input.is_action_just_pressed("ui_select") && hovered_piece != null:
		hovered_piece.select()
		selected_piece = hovered_piece
		state = SelectorState.PieceSelected

func handle_target_select() -> void:
	if Input.is_action_just_pressed("ui_select"):
		var relative_position = chess_board.get_relative_position(position)
		
		if can_piece_move_there(relative_position):
			
			var target = chess_board.opponent_party_at(relative_position)
			
			if target != null:
				selected_piece.deselect()
				state = SelectorState.Idle
				selected_piece.attack_controller.attack(target)
				await selected_piece.attack_controller.attack_finished
				state = SelectorState.PieceSelect
				if selected_piece.move_calculator != null:
					selected_piece.move_calculator.is_first_move = false
				selected_piece = null
			else:
				selected_piece.movement_controller.move_to(chess_board.get_absolute_position(relative_position))
				selected_piece.deselect()
				state = SelectorState.Idle
				await selected_piece.movement_controller.finished_moving
				state = SelectorState.PieceSelect
				if selected_piece.move_calculator != null:
					selected_piece.move_calculator.is_first_move = false
				selected_piece = null


func can_piece_move_there(position: Vector2) -> bool:
	return selected_piece.move_calculator != null && selected_piece.move_calculator.indicator_positions.has(position)

func start_turn() -> void:
	state = SelectorState.PieceSelect


func _on_area_entered(piece: Piece) -> void:
	hovered_piece = piece


func _on_area_exited(piece: Piece) -> void:
	hovered_piece = null
