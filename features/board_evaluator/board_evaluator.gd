class_name BoardEvaluator extends RefCounted

var player: Array[EvaluatorPiece]
var computer: Array[EvaluatorPiece]

func _init(
	chess_board: ChessBoard,

):
	player = EvaluatorPiece.from_pieces(chess_board.player_party.get_pieces(), Constants.Side.Player)
	computer = EvaluatorPiece.from_pieces(chess_board.opponent_party.get_pieces(), Constants.Side.Computer)

func get_board_state() -> Array[Constants.BoardState]:
	var results: Array[Constants.BoardState] = []
	
	if _is_checkmate(Constants.Side.Computer):
		results.append(Constants.BoardState.Checkmate_Computer)
	elif _is_check(Constants.Side.Computer):
		results.append(Constants.BoardState.Check_Computer)
		
	if _is_checkmate(Constants.Side.Player):
		results.append(Constants.BoardState.Checkmate_Player)
	elif _is_check(Constants.Side.Player):
		results.append(Constants.BoardState.Check_Player)
	return results

func simulate_move(move: MoveRecord) -> EvaluatorState:
	var original_state = EvaluatorState.new(
		computer.duplicate(),
		player.duplicate()
	)
	
	for piece in computer + player:
		if piece.is_piece(move.piece):
			piece.position = move.to
	
	if move.captured != null:
		if move.side == Constants.Side.Player:
			computer = computer.filter(func (piece: EvaluatorPiece): return piece._ref == move.captured)
		else:
			player = player.filter(func (piece: EvaluatorPiece): return piece._ref == move.captured)
	
	return original_state

func undo_simulation(state: EvaluatorState) -> void:
	computer = state.computer
	player = state.player

func get_all_possible_moves(side: Constants.Side) -> Array[MoveRecord]:
	var moves: Array[MoveRecord] = []
	
	var pieces = player if side == Constants.Side.Player else computer
	
	for piece in pieces:
		var all_moves = piece.move_calculator._calculate_indicator_positions()
		
		for pos in all_moves:
			var target_piece = _get_piece_at(pos)
			
			if target_piece != null && target_piece.side == side:
				continue
			elif target_piece != null && target_piece.side != side:
				moves.push_back(
					MoveRecord.with_capture(
						piece._ref,
						side,
						piece.position,
						pos,
						target_piece._ref
					)
				)
			else:
				moves.push_back(
					MoveRecord.new(
						piece,
						side,
						piece.get_board_position(),
						pos
					)
				)
			
	return moves

# ==== Private Methods ====

func _is_checkmate(side: Constants.Side) -> bool:
	
	if !_is_check(side):
		return false
	
	var king: EvaluatorPiece = null
	
	var pieces = computer if side == Constants.Side.Computer else player
	
	for piece in pieces:
		if piece.type == Constants.PieceType.King:
			king = piece
			break
			
	assert(king != null, "King is some how null when checking for checkmate")
	
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 && dy == 0:
				continue
				
			var new_pos = king.position + Vector2(dx, dy)
			if !_is_valid_position(new_pos):
				continue
			
			var piece_at_target: EvaluatorPiece = _get_piece_at(new_pos)
			if piece_at_target != null && piece_at_target.side == king.side:
				continue
				
			var orig_pos = king.position
			king.position = new_pos
			var still_in_check = _is_check(side)
			king.position = orig_pos
			
			if !still_in_check:
				return false

	return false
	
func _is_check(side: Constants.Side) -> bool:
	var king_position: Vector2 = _get_king_position(side)
	
	if king_position == null:
		return false
		
	var opposing_side = Constants.get_opposing_side(side)
	
	return _is_square_attacked(king_position, opposing_side)
	
	return false

func _get_king_position (side: Constants.Side) -> Vector2:
	
	var pieces = computer if side == Constants.Side.Computer else player
	
	for piece in pieces:
		if piece.type == Constants.PieceType.King:
			return piece.position
	
	return Vector2.ZERO

func _is_square_attacked(target: Vector2, attacking_side: Constants.Side) -> bool:
	
	var attacking_pieces = computer if attacking_side == Constants.Side.Computer else player
	
	for piece in attacking_pieces:
		if _can_piece_attack_square(piece, target):
			return true
	
	return false

func _can_piece_attack_square(piece: EvaluatorPiece, target: Vector2) -> bool:
	
	match piece.type:
		Constants.PieceType.Pawn:
			return _can_pawn_attack(piece, target)
		Constants.PieceType.Rook:
			return _can_rook_attack(piece, target)
		Constants.PieceType.Knight:
			return _can_knight_attack(piece, target)
		Constants.PieceType.Bishop:
			return _can_bishop_attack(piece, target)
		Constants.PieceType.King:
			return _can_king_attack(piece, target)
		Constants.PieceType.Queen:
			return _can_queen_attack(piece, target)
	
	return false

func _can_pawn_attack(piece: EvaluatorPiece, target: Vector2) -> bool:
	var direction = 1 if piece.side == Constants.Side.Player else -1
	return abs(piece.position.x - target.x) == 1\
			&& piece.position.y + direction == target.y

func _can_rook_attack(piece: EvaluatorPiece, target: Vector2) -> bool:
	if piece.position.x != target.x && piece.position.y != target.y:
		return false
	return _is_path_clear(piece.position, target)

func _can_knight_attack(piece: EvaluatorPiece, target: Vector2) -> bool:
	var dx = abs(piece.position.x - target.x)
	var dy = abs(piece.position.y - target.y)
	
	return (dx == 2 && dy == 1) || (dx ==1 && dy == 2)

func _can_bishop_attack(piece: EvaluatorPiece, target: Vector2) -> bool:
	if abs(piece.position.x - target.x) != abs(piece.position.y - target.y):
		return false
	return _is_path_clear(piece.position, target)

func _can_king_attack(piece: EvaluatorPiece, target: Vector2) -> bool:
	var dx = abs(piece.position.x - target.x)
	var dy = abs(piece.position.y - target.y)
	
	return dx <= 1 && dy <= 1 && (dx != 0 || dy != 0)

func _can_queen_attack(piece: EvaluatorPiece, target: Vector2) -> bool:
	return _can_bishop_attack(piece, target) || _can_rook_attack(piece, target)

func _is_path_clear(start: Vector2, end: Vector2) -> bool:
	
	var d = end - start
	
	var step = Vector2(
		0 if d.x == 0 else d.x / abs(d.x),
		0 if d.y == 0 else d.y / abs(d.y),
	)
	
	var current = start + step
	
	while current != end:
		if _get_piece_at(current) != null:
			return false
		current += step
	
	return true

func _get_piece_at(position: Vector2):
	for piece in player + computer:
		if piece.position == position:
			return piece
			
	return null

func _is_valid_position(position: Vector2) -> bool:
	return position.x > 0 && position.x <= 8 && position.y > 0 && position.y <= 8

class EvaluatorPiece extends RefCounted:
	
	var type: Constants.PieceType
	var position: Vector2
	var side: Constants.Side
	var original_position: Vector2
	
	var _ref: Piece
	
	func _init(
		i_type: Constants.PieceType,
		i_position: Vector2,
		i_side: Constants.Side,
		i_ref: Piece
	):
		type = i_type
		position = i_position
		original_position = i_position
		side = i_side
		_ref = i_ref
	
	func is_piece(piece: Piece) -> bool:
		return piece.get_board_position() == position\
				&& piece.piece_type == type
	
	static func from_pieces(pieces: Array[Piece], side: Constants.Side) -> Array[EvaluatorPiece]:
		var results: Array[EvaluatorPiece] = []
		
		for piece in pieces:
			results.push_back(EvaluatorPiece.new(
				piece.piece_type,
				piece.get_board_position(),
				side,
				piece
			))

		return results
	
class Move extends RefCounted:
	
	var piece: EvaluatorPiece
	var target: Vector2
	
	func _init(i_piece: EvaluatorPiece, i_target: Vector2):
		piece = i_piece
		target = i_target
		
	func debug():
		var piece_name = Constants.piece_type_to_string(piece.type)
		print(
			"%s at %s to %s" % [
				piece_name,
				piece.original_position,
				target
			]
		)

class EvaluatorState extends RefCounted:
	var player: Array[EvaluatorPiece]
	var computer: Array[EvaluatorPiece]
	var is_in_check: bool = false
	
	func _init(i_player: Array[EvaluatorPiece], i_computer: Array[EvaluatorPiece]):
		player = i_player
		computer = i_computer
