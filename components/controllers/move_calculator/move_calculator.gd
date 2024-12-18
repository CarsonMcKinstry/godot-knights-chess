class_name MoveCalculator extends Node

@export var piece: Piece

enum CalculatorState {
	Idle,
	Showing
}

var state: CalculatorState = CalculatorState.Idle

func _ready():
	piece.finished_entering.connect(handle_piece_ready, CONNECT_ONE_SHOT)

func handle_piece_ready():
	state = CalculatorState.Showing
	
