class_name MoveRandomizer extends MoveSelector

func choose(chess_board: ChessBoard, party: PartyController) -> MoveRecord:
	var all_possible_moves: Array[MoveRecord] = []
	
	for piece in party.get_pieces():
		var moves = piece.get_all_possible_moves()
		all_possible_moves.append_array(moves)
	
	all_possible_moves.shuffle()
	
	var move
	
	while !all_possible_moves.is_empty():
		var temp = all_possible_moves.pop_front()
		var is_valid_move = chess_board.validate_move(temp)
		
		if is_valid_move:
			move = temp
			break
			
	return move
