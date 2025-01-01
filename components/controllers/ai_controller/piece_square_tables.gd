class_name PieceSquareTables extends Node

@export_file("*.json") var pst_file

@onready var pst_computer: Dictionary = _load_pst()
@onready var pst_player: Dictionary = _load_pst_player(pst_computer)

@onready var pst_opponent = {
	Constants.Side.Computer: pst_player,
	Constants.Side.Player: pst_computer
}

@onready var pst_self = {
	Constants.Side.Computer: pst_computer,
	Constants.Side.Player: pst_player
}

func get_own_position_value(move: MoveRecord, piece_type: Constants.PieceType, pos: Vector2) -> int:
	return _get_position_value(pst_self, move.side, move.piece.piece_type, move.is_end_game, pos)
	
func get_opponent_position_value(move: MoveRecord, piece_type: Constants.PieceType, pos: Vector2) -> int:
	return _get_position_value(pst_opponent, move.side, move.piece.piece_type, move.is_end_game, pos)

func _get_position_value(
	table: Dictionary,
	side: Constants.Side,
	piece_type: Constants.PieceType,
	is_end_game: bool,
	pos: Vector2
) -> int:
	
	var piece_short_code: String
	
	match piece_type:
		Constants.PieceType.Pawn:
			piece_short_code = "p"
		Constants.PieceType.Knight:
			piece_short_code = "n"
		Constants.PieceType.Bishop:
			piece_short_code = "b"
		Constants.PieceType.Rook:
			piece_short_code = "r"
		Constants.PieceType.Queen:
			piece_short_code = "q"
		Constants.PieceType.King:
			if is_end_game:
				piece_short_code = "k_e"
			else:
				piece_short_code = "k"

	var value_lookup = table[side]
	
	assert(value_lookup != null, "No lookup table found for %s " % [Constants.side_to_string(side)])

	var piece_values = value_lookup[piece_short_code]
	
	assert(piece_values, "No piece values found for %s " % [piece_short_code])

	return piece_values[pos.x][pos.y]
func _load_pst():
	if FileAccess.file_exists(pst_file):
		var data_file = FileAccess.open(pst_file, FileAccess.READ)
		
		var json = JSON.new()
		var parsed_pst = json.parse_string(data_file.get_as_text())
		
		if parsed_pst is Dictionary:
			return parsed_pst
		else:
			print("Error reading file")
	else:
		print("File doesn't exist!")

func _load_pst_player(pst: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	
	for key in pst.keys():
		var values = pst[key].duplicate();
		values.reverse()
		out[key] = values
	
	return out
