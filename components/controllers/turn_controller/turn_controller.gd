class_name TurnController extends Node

@export var player_controller: Selector
@export var ai_controller: AiController

@export var chess_board: ChessBoard

@export var info_label: Label

enum Turn {
	Player,
	Computer
}

var current_turn: Turn:
	set(next_state):
		current_turn = next_state
		handle_next_turn()

func _ready():
	player_controller.turn_finished.connect(handle_turn_finished)
	ai_controller.turn_finished.connect(handle_turn_finished)

func start():
	current_turn = Turn.Player

func handle_turn_finished():
	match current_turn:
		Turn.Player:
			current_turn = Turn.Computer
		Turn.Computer:
			current_turn = Turn.Player

func handle_next_turn():
	
	var evaluator = BoardEvaluator.new(chess_board)

	var board_state = evaluator.get_board_state()
	
	if board_state.has(Constants.BoardState.Checkmate_Computer):
		print("Checkmate computer! Player Wins")
	elif board_state.has(Constants.BoardState.Checkmate_Player):
		print("Checkmate Player! Computer Wins")
	else:
		match current_turn:
			Turn.Player:
				update_player_en_passant()
				info_label.text = "Player's Turn"
				player_controller.start_turn()
			Turn.Computer:
				update_opponent_en_passant()
				info_label.text = "Computer's Turn"
				ai_controller.start_turn()

func update_player_en_passant():
	for piece in chess_board.player_party.get_pieces():
		piece.capturable_by_en_passant = false
		
func update_opponent_en_passant():
	for piece in chess_board.opponent_party.get_pieces():
		piece.capturable_by_en_passant = false
