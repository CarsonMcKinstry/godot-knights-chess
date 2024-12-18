class_name Selector extends Area2D

@export var sprite: AnimatedSprite2D
@export var movement_controller: GridController
@export var chess_board: ChessBoard
@export var player_party: PartyController
@export var opponent_party: PartyController

enum SelectorState {
	PieceSelect, # Choosing a piece to move
	PieceHovered,
	PieceSelected, # Piece has been choosen
	Idle, # Waiting for the piece to finish moving
}

var state: SelectorState = SelectorState.Idle

func _physics_process(_delta: float):
	
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
		SelectorState.PieceHovered:
			pass
		SelectorState.PieceSelected:
			pass
		SelectorState.Idle:
			pass
			
func handle_move():
	var direction = movement_controller.get_movement_direction()
	
	if direction != Vector2.ZERO:
		if chess_board != null:
			if !chess_board.is_direction_out_of_bounds(position, direction):
				movement_controller.move_in(direction)
				await movement_controller.finished_moving
		else:
			movement_controller.move_in(direction)
			await movement_controller.finished_moving
		
func handle_select():
	pass
	
func start():
	state = SelectorState.PieceSelect
	
