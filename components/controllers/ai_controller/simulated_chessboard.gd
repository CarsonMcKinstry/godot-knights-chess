class_name SimulatedChessBoard extends RefCounted

var computer_pieces: Array[SimulatedPiece]
var player_pieces: Array[SimulatedPiece]

const PIECE_VALUES = {
	Piece.PieceType.Pawn: 100,
	Piece.PieceType.Knight: 350,
	Piece.PieceType.Bishop: 350,
	Piece.PieceType.Rook: 525,
	Piece.PieceType.Queen: 1000,
	Piece.PieceType.King: 10000,
}

enum BoardState {
	Check_AI,
	Check_Player,
	Checkmate_AI,
	Checkmate_Player,
	
}

static func from(i_chess_board: ChessBoard) -> SimulatedChessBoard:
	var board = SimulatedChessBoard.new()
	
	for piece in i_chess_board.opponent_party.get_pieces():
		board.computer_pieces.push_back(
			SimulatedPiece.from(piece, SimulatedPiece.Side.AI)
		)
	
	for piece in i_chess_board.player_party.get_pieces():
		board.player_pieces.push_back(
			SimulatedPiece.from(piece, SimulatedPiece.Side.Player)
		)
	
	return board

func evaluate() -> int:
	var value = 0
	
	for piece in computer_pieces:
		value += PIECE_VALUES[piece.ref.piece_type]
		
	for piece in player_pieces:
		value -= PIECE_VALUES[piece.ref.piece_type]
	
	return value

func evaluate_move(move: SimulatedMove) -> int:
	
	var original = simulate_move(move)
	
	var score = evaluate()
	
	undo(original)
	
	return score

func simulate_move(move: SimulatedMove) -> Tuple2:
	
	var side = move.piece.side
	
	var original = Tuple2.from(
		computer_pieces.duplicate(),
		player_pieces.duplicate()
	)
	
	# super naive filter
	computer_pieces = computer_pieces.filter(\
		func (piece: SimulatedPiece): return piece.position != move.to_position\
	)
	
	player_pieces = player_pieces.filter(\
		func (piece: SimulatedPiece): return piece.position != move.to_position\
	)
	
	return original

func undo(original: Tuple2):
	computer_pieces = original.x
	player_pieces = original.y

func get_all_possible_moves() -> Array[SimulatedMove]:
	var moves: Array[SimulatedMove] = []
	
	for piece in computer_pieces:
		var all_moves = piece.ref.get_all_possible_moves()
		
		for move in all_moves:
			moves.push_back(
				SimulatedMove.from(
					piece,
					move
				)
			)
	
	return moves
