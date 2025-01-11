class_name MatchConfig extends Resource

@export var player_party: PartyConfig
@export var computer_party: PartyConfig



func start_match(
	chess_board: ChessBoard,
	player_party_controller: PartyController,
	computer_party_controller: PartyController
):
	_build_party(player_party, chess_board, player_party_controller)
	_build_party(computer_party, chess_board, computer_party_controller)

func _build_party(party_config: PartyConfig, chess_board: ChessBoard, controller: PartyController):
	for piece_config in party_config.pieces:
		piece_config.setup(
			controller,
			chess_board,
			party_config.base_color,
			party_config.shadow_color
		)
