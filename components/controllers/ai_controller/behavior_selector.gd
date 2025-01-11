class_name BehaviorSelector extends Node

@export var default_bavior: MoveSelector

func get_move(chess_board: ChessBoard, party: PartyController, behavior: String = "") -> MoveRecord:
	
	var selectors = _get_selectors()
	
	var selector: MoveSelector = selectors.get(behavior)
	
	if selector != null:
		return selector.choose(chess_board, party)
	else:
		return default_bavior.choose(chess_board, party)
	
func _get_selectors() -> Dictionary:
	var selectors = {}
	
	for child in get_children():
		if child is MoveSelector:
			selectors[child.selector_name] = child
		
	return selectors
