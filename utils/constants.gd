class_name Constants extends RefCounted

enum PieceType {
	Pawn, # 0
	Rook, # 1
	Knight, # 2
	Bishop, # 3
	King, # 4
	Queen # 5
}

static func piece_type_to_string(type: Constants.PieceType) -> String:
	match type:
		Constants.PieceType.Pawn:
			return "Pawn"
		Constants.PieceType.Rook:
			return "Rook"
		Constants.PieceType.Knight:
			return "Knight"
		Constants.PieceType.Bishop:
			return "Bishop"
		Constants.PieceType.King:
			return "King"
		Constants.PieceType.Queen:
			return "Queen"
	return "UNKNOWN PIECE TYPE"

enum Side {
	Player,
	Computer
}

static func side_to_string(side: Constants.Side) -> String:
	match side:
		Constants.Side.Player:
			return "Player"
		Constants.Side.Computer:
			return "Computer"
	return "UNKNOWN SIDE"

static func get_opposing_side(side: Constants.Side) -> Constants.Side:
	match side:
		Side.Player:
			return Side.Computer
		Side.Computer:
			return Side.Player
	
	return Side.Player

enum Facing {
	Left,
	Right
}

static func facing_to_string(facing: Constants.Facing) -> String :
	match facing:
		Constants.Facing.Left:
			return "Left"
		Constants.Facing.Right:
			return "Right"
	return "UKNOWN FACING"

enum BoardState {
	Check_Computer,
	Check_Player,
	Checkmate_Computer,
	Checkmate_Player
}
