class_name TurnController extends Node

@export var player_controller: Selector
@export var ai_controller: AiController

@export var info_label: Label

enum Turn {
	Player,
	AI
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
	# eventually, this will check win conditions
	match current_turn:
		Turn.Player:
			current_turn = Turn.AI
		Turn.AI:
			current_turn = Turn.Player

func handle_next_turn():
	match current_turn:
		Turn.Player:
			info_label.text = "Player's Turn"
			player_controller.start_turn()
		Turn.AI:
			info_label.text = "Computer's Turn"
			ai_controller.start_turn()
