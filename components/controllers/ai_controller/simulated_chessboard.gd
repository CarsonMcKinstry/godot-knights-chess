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
	Checkmate_Player
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
	
	if is_check(SimulatedChessBoard.Side.AI):
		return -INF
	
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
	
	for piece in computer_pieces + player_pieces:

		if piece.ref == move.piece.ref:
			piece.position = move.to_position

	return original

func simulate_move_for_piece(piece: Piece, position: Vector2, side: SimulatedChessBoard.Side) -> void:
	var simulated_piece = SimulatedPiece.from(piece, side)
	var simulated_move = SimulatedMove.from(simulated_piece, position)
	
	simulate_move(simulated_move)

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
		results.append(BoardState.Checkmate_Player)
	elif is_check(SimulatedChessBoard.Side.Player):
		results.append(BoardState.Check_Player)
	
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
		var res = can_piece_attack_square(piece, pos)
		if res:
			return true
	
	return false

func can_piece_attack_square(piece: SimulatedPiece, target: Vector2) -> bool:
	match piece.ref.piece_type:
		Piece.PieceType.Pawn:
			return can_pawn_attack(piece, target)
		Piece.PieceType.Rook:
			return can_rook_attack(piece, target)
		Piece.PieceType.Knight:
			return can_knight_attack(piece, target)
		Piece.PieceType.Bishop:
			return can_bishop_attack(piece, target)
		Piece.PieceType.King:
			return can_king_attack(piece, target)
		Piece.PieceType.Queen:
			return can_queen_attack(piece, target)
	
	return false

func can_pawn_attack(piece: SimulatedPiece, target: Vector2) -> bool:
	var direction = 1 if piece.side == SimulatedChessBoard.Side.Player else -1
	return (abs(piece.position.x - target.x) == 1 and
			piece.position.y + direction == target.y)
	
func can_rook_attack(piece: SimulatedPiece, target: Vector2) -> bool:
	if piece.position.x != target.x && piece.position.y != target.y:
		return false
	return is_path_clear(piece.position, target)
	
func can_knight_attack(piece: SimulatedPiece, target: Vector2) -> bool:
	var dx = abs(piece.position.x - target.x)
	var dy = abs(piece.position.y - target.y)
	return (dx == 2 and dy == 1) or (dx == 1 and dy == 2)
	
func can_bishop_attack(piece: SimulatedPiece, target: Vector2) -> bool:
	if abs(piece.position.x - target.x) != abs(piece.position.y - target.y):
		return false
	return is_path_clear(piece.position, target)
	
func can_king_attack(piece: SimulatedPiece, target: Vector2) -> bool:
	var dx = abs(piece.position.x - target.x)
	var dy = abs(piece.position.y - target.y)
	return dx <= 1 and dy <= 1 and (dx != 0 or dy != 0)
	
func can_queen_attack(piece: SimulatedPiece, target: Vector2) -> bool:
	return can_bishop_attack(piece, target) or can_rook_attack(piece, target)

func is_path_clear(start: Vector2, end: Vector2) -> bool:
	var dx = end.x - start.x
	var dy = end.y - start.y
	
	var step = Vector2(
		0 if dx == 0 else dx / abs(dx),
		0 if dy == 0 else dy / abs(dy)
	)
	
	var current = start + step
	
	while current != end:
		if get_piece_at(current) != null:
			return false
		current += step
	
	return true

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
