class_name SimulatedPiece extends RefCounted

var ref: Piece
var position: Vector2
var side: Side

static func from(i_piece: Piece, i_side: SimulatedChessBoard.Side) -> SimulatedPiece:
	
	var piece = SimulatedPiece.new()
	
	piece.ref = i_piece
	piece.position = i_piece.get_board_position()
	piece.side = i_side
	
	return piece
