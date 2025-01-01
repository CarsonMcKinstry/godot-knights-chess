class_name ChessBoard extends Area2D

@export var grid_line: Line2D
@export var grid_lines: Node2D

@export var player_party: PartyController
@export var computer_party: PartyController

const UPPER_BOUND = 7
const LOWER_BOUND = 0
const LEFT_BOUND = 0
const RIGHT_BOUND = 7

const RELATIVE_OFFSET: Vector2 = Vector2(-16, -16)
const POSITION_CORRECTION: Vector2 = Vector2(5, 5)
const GRID_OFFSET = Vector2(128, 128)

var moves: Array[MoveRecord] = []

var resolved_moves: Array[MoveRecord] = []

func _ready() -> void:
	
	for y in range(0, 9):
		var line = grid_line.duplicate()
		for x in range(0, 9):
			line.add_point(Vector2(-128 + x * 32, -128 + y * 32))
		grid_lines.add_child(line)

	for x in range(0, 9):
		var line = grid_line.duplicate()
		for y in range(0, 9):
			line.add_point(Vector2(-128 + x * 32, -128 + y * 32))
		grid_lines.add_child(line)

func enqueue_move(move: MoveRecord): 
	resolved_moves.push_front(move)
	apply_piece_updates()

func undo():
	while !resolved_moves.is_empty():
		var move: MoveRecord = resolved_moves.pop_front()
		move.undo()

func undo_last_move():
	var move: MoveRecord = resolved_moves.pop_front()
	
	if move != null:
		move.undo()

func apply_piece_updates():
	for move in resolved_moves:
		move.apply()

func resolve_latest_move():
	assert(!resolved_moves.is_empty(), "can't resolve no moves")
	
	var move = resolved_moves.pop_back()
	print(move.serialize())

	await move.resolve(self)
	
	moves.push_front(move)

func validate_move(move: MoveRecord) -> bool:
	var side = move.piece.party.side
	# verify that the move doesn't put, or leave, their king in check
	move.apply()
	
	var king = move.piece if move.piece.piece_type == Constants.PieceType.King else get_king_for(side)
	
	if king == null:
		move.undo()
		return false
	
	var king_under_attack = is_position_under_attack_by(king.grid_position, Constants.get_opposing_side(side))
	
	move.undo()
	
	return !king_under_attack

func player() -> Array[Piece]:
	return player_party.get_pieces()
	
func computer() -> Array[Piece]:
	return computer_party.get_pieces()

func pieces() -> Array[Piece]:
	return player() + computer()

func get_grid_position(canvas_pos: Vector2) -> Vector2:
	return ((canvas_pos + RELATIVE_OFFSET) / 32 ) + POSITION_CORRECTION - Vector2.ONE

func get_canvas_position(grid_pos: Vector2) -> Vector2:
	
	return (grid_pos * 32) - RELATIVE_OFFSET - GRID_OFFSET
	
func get_piece_at(grid_pos: Vector2) -> Piece:
	for piece in pieces():
		if piece.grid_position == grid_pos && !piece.is_dead:
			return piece
	return null
	
func get_pieces_of_type(type: Constants.PieceType, side: Constants.Side) -> Array[Piece]:
	var pieces_of_type: Array[Piece] = []
	
	var pieces = player() if side == Constants.Side.Player else computer()
	
	for piece in pieces:
		if !piece.is_dead && piece.has_type(type):
			pieces_of_type.push_back(piece)
	
	return pieces_of_type

func get_all_possible_moves_for(side: Constants.Side) -> Array[MoveRecord]:
	var all_possible_moves: Array[MoveRecord] = []
	
	var pieces = player() if side == Constants.Side.Player else computer()
	
	for piece in pieces:
		all_possible_moves.append_array(piece.get_all_possible_moves())
	
	return all_possible_moves

func in_checkmate() -> bool:
	return is_checkmate(Constants.Side.Computer) || is_checkmate(Constants.Side.Player)

func in_check() -> bool:
	return is_check(Constants.Side.Computer) || is_check(Constants.Side.Player)

func is_checkmate(side: Constants.Side) -> bool:
	if !is_check(side):
		return false
		
	var king = get_king_for(side)
	
	if king == null:
		return true

	for dx in [-1,0,1]:
		for dy in [-1,0,1]:
			var pos = Vector2(dx, dy)
			
			if pos == Vector2.ZERO:
				continue
				
			var next_position = king.grid_position + pos
			
			if is_position_out_of_bounds(next_position):
				continue
			
			var move = MoveRecord.new(
				side,
				king,
				king.grid_position,
				next_position
			)
			
			var piece_at_target = get_piece_at(next_position)
			if piece_at_target != null && piece_at_target.party.side == side:
				continue
			elif piece_at_target != null:
				move = move.with_captured(piece_at_target)

			move.apply()
			var still_in_check = is_check(side)
			
			move.undo()
			
			if !still_in_check:
				return false
	
	return true

func is_check(side: Constants.Side) -> bool:
	
	var king = get_king_for(side)
	
	if king == null:
		return true
	
	var opposing_side = Constants.get_opposing_side(side)
	
	return is_position_under_attack_by(king.grid_position, opposing_side)

func is_draw(side: Constants.Side) -> bool:
	if is_stalemate(side):
		return true

	if is_threefold_repetition():
		return true
	
	# Additional checks can go here, like insufficient material
	if has_insufficient_material():
		return true
	
	return false

func is_stalemate(side: Constants.Side) -> bool:
	if is_check(side):
		return false
	
	var pieces = player() if side == Constants.Side.Player else computer()
	
	for piece in pieces:
		if !piece.is_iead:
			var possible_moves = piece.get_all_possible_moves()
			for move in possible_moves:
				move.apply()
				var still_in_check = is_check(side)
				move.undo()
				
				if !still_in_check:
					return false

	return true

func is_threefold_repetition() -> bool:
	var position_counts = {}
	
	for move in moves:
		var key = move.serialize()
		
		if position_counts.has(key):
			position_counts[key] += 1
		else:
			position_counts[key] = 1
			
		if position_counts[key] >= 3:
			return true
			
	return false

func has_insufficient_material() -> bool:
	var all_pieces = pieces()
	var non_pawn_pieces = []

	for piece in all_pieces:
		if !piece.is_dead:
			if piece.piece_type in [Constants.PieceType.Queen, Constants.PieceType.Rook, Constants.PieceType.Pawn]:
				return false
		non_pawn_pieces.append(piece)

	# If only kings are left, or one side has a bishop/knight, it’s insufficient
	return len(non_pawn_pieces) <= 2

func is_direction_out_of_bounds(pos: Vector2, direction: Vector2) -> bool:
	
	var relative_position = get_grid_position(pos)
	
	match direction:
		Vector2.UP:
			return relative_position.y == LOWER_BOUND
		Vector2.RIGHT:
			return relative_position.x == RIGHT_BOUND
		Vector2.DOWN:
			return relative_position.y == UPPER_BOUND
		Vector2.LEFT:
			return relative_position.x == LEFT_BOUND

	return false

func is_position_out_of_bounds(grid_position: Vector2) -> bool:
	return grid_position.x < LEFT_BOUND || grid_position.x > RIGHT_BOUND || grid_position.y < LOWER_BOUND || grid_position.y > UPPER_BOUND

func is_position_under_attack_by(grid_position: Vector2, side: Constants.Side) -> bool:
	
	var pieces = player() if side == Constants.Side.Player else computer()
	
	for piece in pieces:
		if _can_piece_attack_square(piece, grid_position):
			return true
	
	return false

func get_king_for(side: Constants.Side) -> Piece:
	var pieces = player() if side == Constants.Side.Player else computer()
	
	var king: Piece
	
	for piece in pieces:
		if piece.piece_type == Constants.PieceType.King:
			king = piece
			break
			
	return king

func _can_piece_attack_square(piece: Piece, target: Vector2) -> bool:
	
	match piece.piece_type:
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
#
func _can_pawn_attack(piece: Piece, target: Vector2) -> bool:
	var direction = 1 if piece.party.side == Constants.Side.Player else -1
	return abs(piece.grid_position.x - target.x) == 1\
			&& piece.grid_position.y + direction == target.y

func _can_rook_attack(piece: Piece, target: Vector2) -> bool:
	if piece.grid_position.x != target.x && piece.grid_position.y != target.y:
		return false
	return _is_path_clear(piece.grid_position, target)

func _can_knight_attack(piece: Piece, target: Vector2) -> bool:
	var dx = abs(piece.grid_position.x - target.x)
	var dy = abs(piece.grid_position.y - target.y)
	
	return (dx == 2 && dy == 1) || (dx ==1 && dy == 2)

func _can_bishop_attack(piece: Piece, target: Vector2) -> bool:
	if abs(piece.grid_position.x - target.x) != abs(piece.grid_position.y - target.y):
		return false
	return _is_path_clear(piece.grid_position, target)

func _can_king_attack(piece: Piece, target: Vector2) -> bool:
	var dx = abs(piece.grid_position.x - target.x)
	var dy = abs(piece.grid_position.y - target.y)
	
	return dx <= 1 && dy <= 1 && (dx != 0 || dy != 0)

func _can_queen_attack(piece: Piece, target: Vector2) -> bool:
	return _can_bishop_attack(piece, target) || _can_rook_attack(piece, target)

func _is_path_clear(start: Vector2, end: Vector2) -> bool:
	
	var d = end - start
	
	var step = Vector2(
		0 if d.x == 0 else d.x / abs(d.x),
		0 if d.y == 0 else d.y / abs(d.y),
	)
	
	var current = start + step
	
	while current != end:
		if get_piece_at(current) != null:
			return false
		current += step
	
	return true
