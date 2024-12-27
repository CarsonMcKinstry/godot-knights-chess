class_name AiController extends Node

signal turn_finished

@export var party: PartyController
@export var chess_board: ChessBoard

@export_file("*.json") var pst_file

@onready var pst_computer: Dictionary = load_pst()
@onready var pst_player: Dictionary = load_pst_player(pst_computer)

const PIECE_WEIGHTS = {
	Constants.PieceType.Pawn: 100,
	Constants.PieceType.Knight: 280,
	Constants.PieceType.Bishop: 320,
	Constants.PieceType.Rook: 479,
	Constants.PieceType.Queen: 929,
	Constants.PieceType.King: 60_000,
}

func start_turn():
	turn_finished.emit()

# ===== PST LOADERS =====
func load_pst():
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

func load_pst_player(pst: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	
	for key in pst.keys():
		var values = pst[key].duplicate();
		values.reverse()
		out[key] = values
	
	return out
	
