class_name MoveCalculator extends Node

@onready var tile_indicator_scene = preload("res://features/tile_indicator/tile_indicator.tscn")

@export var piece: Piece
@export var tile_indicators: Node2D

# only applies to pawns
var is_first_move = true

var indicator_positions: Array[Vector2] = []

enum CalculatorState {
	Idle,
	Showing
}

var state: CalculatorState = CalculatorState.Idle:
	set(next_state):
		state = next_state
		
		match next_state:
			CalculatorState.Idle:
				handle_idle()
			CalculatorState.Showing:
				_calculate_indicator_positions()
				render_indicators()
				

func render_indicators():
	for pos in indicator_positions:
		var indicator: Node2D = tile_indicator_scene.instantiate()
		indicator.position = to_chess_board_position(pos)
		tile_indicators.add_child(indicator)

func show_indicators():
	state = CalculatorState.Showing

func hide_indicators():
	state = CalculatorState.Idle

func handle_idle():
	for child in tile_indicators.get_children():
		child.queue_free()
	
func _calculate_indicator_positions():
	pass

func to_chess_board_positions(positions: Array[Vector2]) -> Array[Vector2]:
	var mapped_positions: Array[Vector2] = []
	
	for pos in positions:
		mapped_positions.push_back(to_chess_board_position(pos))
		
	return mapped_positions
	
func to_chess_board_position(pos: Vector2) -> Vector2:
	return piece.chess_board.get_absolute_position(pos) + piece.chess_board.position
	