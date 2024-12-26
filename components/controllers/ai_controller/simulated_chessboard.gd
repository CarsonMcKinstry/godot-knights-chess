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

enum Side {
	Player,
	AI
}

enum BoardState {
	Undecided,
	Check_AI,
	Check_Player,
	Checkmate_AI,
	Ceckmate_Player
}

static func from(i_chess_board: ChessBoard) -> SimulatedChessBoard:
	var board = SimulatedChessBoard.new()
	
	for piece in i_chess_board.opponent_party.get_pieces():
		board.computer_pieces.push_back(
			SimulatedPiece.from(piece, Side.AI)
		)
	
	for piece in i_chess_board.player_party.get_pieces():
		board.player_pieces.push_back(
			SimulatedPiece.from(piece, Side.Player)
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

func calculate_endgame_state() -> Array[BoardState]:
	
	var results: Array[BoardState] = []
	
	if is_checkmate(SimulatedChessBoard.Side.AI):
		results.append(BoardState.Checkmate_AI)
	elif is_check(SimulatedChessBoard.Side.AI):
		results.append(BoardState.Check_AI)
	
	
	if is_checkmate(SimulatedChessBoard.Side.Player):
		results.append(BoardState.Checkmate_AI)
	elif is_check(SimulatedChessBoard.Side.Player):
		results.append(BoardState.Check_AI)
	
	return results
	

func is_valid_position(position: Vector2) -> bool:
	return position.x > 0 && position.x <= 8 && position.y > 0 && position.y <= 8

func get_piece_at(position: Vector2):
	for piece in computer_pieces + player_pieces:
		if piece.position == position:
			return piece
			
	return null

func get_king_position(side: SimulatedChessBoard.Side) -> Vector2:
	var pieces = computer_pieces if side == SimulatedChessBoard.Side.AI else player_pieces
	for piece in pieces:
		if piece.ref.piece_type == Piece.PieceType.King:
			return piece.position

	return Vector2.ZERO

func is_square_attacked(pos: Vector2, attacking_side: SimulatedChessBoard.Side) -> bool:
	
	var attacking_pieces = computer_pieces if attacking_side == SimulatedChessBoard.Side.AI else player_pieces
	
	for piece in attacking_pieces:
		var positions_under_attack = piece.ref.get_all_possible_attacks()
		
		if positions_under_attack.has(pos):
			return true
	
	return false

func is_check(side: SimulatedChessBoard.Side):
	var king_position: Vector2 = get_king_position(side)
	
	if king_position == null:
		return false
	
	var opposing_side = get_opposing_side(side)
	
	return is_square_attacked(king_position, opposing_side)

func is_checkmate(side: SimulatedChessBoard.Side) -> bool:
	if !is_check(side):
		return false
		
	var king: SimulatedPiece = null
	
	var pieces = computer_pieces if side == SimulatedChessBoard.Side.AI else player_pieces
		
	for piece in pieces:
		if piece.ref.piece_type == Piece.PieceType.King:
			king = piece
			break
	
	if king == null:
		return false
	
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
		
			var new_position = king.position + Vector2(dx, dy)
			if !is_valid_position(new_position):
				continue
			
			var piece_at_target: SimulatedPiece = get_piece_at(new_position)
			if piece_at_target == null:
				continue
				
			var original_position = king.position
			king.position = new_position
			var still_in_check = is_check(side)
			king.position = original_position
			
			if !still_in_check:
				return false
			
	return true

func get_opposing_side(side: SimulatedChessBoard.Side) -> SimulatedChessBoard.Side:
	if side == SimulatedChessBoard.Side.Player:
		return SimulatedChessBoard.Side.AI
	else:
		return SimulatedChessBoard.Side.Player
