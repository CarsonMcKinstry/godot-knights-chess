class_name Main extends Node2D

@export var player_party: PartyController
@export var opponent_party: PartyController

@export var selector: Selector

@export var turn_controller: TurnController

@export var match_config: MatchConfig

@export var use_config: bool = false

@export var chess_board: ChessBoard

@export var hud: Control

var parties_ready: bool = false

func _ready():
	match_config.start_match(chess_board, player_party, opponent_party)

func _process(delta):
	if !parties_ready:
		parties_ready = player_party.is_ready() && opponent_party.is_ready()
		if parties_ready:
			turn_controller.start()
