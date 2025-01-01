class_name BoardEvaluator extends Node

@export var pst: PieceSquareTables

const PIECE_WEIGHTS = {
	Constants.PieceType.Pawn: 100,
	Constants.PieceType.Knight: 280,
	Constants.PieceType.Bishop: 320,
	Constants.PieceType.Rook: 479,
	Constants.PieceType.Queen: 929,
	Constants.PieceType.King: 60_000,
}

func evaluate_board(chess_board: ChessBoard, move: MoveRecord, prev_sum: int, side: Constants.Side) -> int:
	var new_sum = prev_sum

	if chess_board.in_checkmate():
		if move.side == side:
			return 10 ** 10
		else:
			return -(10 ** 10)
	
	if chess_board.is_draw(side):
		return 0
	
	if chess_board.in_check():
		if move.side == side:
			new_sum += 50
		else:
			new_sum -= 50
	
	var from = move.from
	var to = move.to
	
	if prev_sum < -1500:
		if move.piece.piece_type == Constants.PieceType.King:
			move.is_end_game = true
		elif move.captured != null && move.captured.piece_type == Constants.PieceType.King:
			move.is_end_game = true
			
	if move.captured != null:
		var captured = move.captured.piece_type
		if move.side == side:
			new_sum += _get_weight(captured) + pst.get_opponent_position_value(move, captured, to)
		else:
			new_sum -= _get_weight(captured) + pst.get_own_position_value(move, captured, to)
	
	if move.promoted_to != null:
		var original_piece_type = move.piece.piece_type
		var promoted_to = move.promoted_to
		
		var change_from_original = _get_weight(original_piece_type) + pst.get_own_position_value(move, original_piece_type, from)
		var change_from_promotion = _get_weight(promoted_to) + pst.get_own_position_value(move, promoted_to, to)
		
		if move.side == side:
			new_sum -= change_from_original
			new_sum += change_from_promotion
		else:
			new_sum += change_from_original
			new_sum -= change_from_promotion
	else:
		var piece_type = move.piece.piece_type
		var from_change = pst.get_own_position_value(move, piece_type, from)
		var to_change = pst.get_own_position_value(move, piece_type, to)
		
		if move.side == side:
			new_sum += from_change
			new_sum -= to_change
		else:
			new_sum -= from_change
			new_sum += to_change

	return new_sum



static func _get_weight(piece_type: Constants.PieceType) -> int:
	assert(piece_type in PIECE_WEIGHTS, "Weight not found for %s" % [Constants.piece_type_to_string(piece_type)])
	
	return PIECE_WEIGHTS.get(piece_type)
