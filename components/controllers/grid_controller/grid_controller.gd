class_name GridController extends Node

@export var body: Node2D
@export var speed: int = 150
@export var move_by: int = 32

signal finished_moving
signal state_changed(GridControllerState)
signal facing_changed(Facing)
signal moving

enum GridControllerState {
	Idle,
	Moving
}

var target_pos: Vector2

var state: GridControllerState = GridControllerState.Idle:
	set(next_state):
		state_changed.emit(next_state)
		state = next_state

var facing: Constants.Facing = Constants.Facing.Right:
	set(next_state):
		facing_changed.emit(next_state)
		facing = next_state

var initial_facing: Constants.Facing

func _ready():
	facing_changed.emit(facing)

func _physics_process(delta: float):
	match state:
		GridControllerState.Idle:
			pass
		GridControllerState.Moving:
			handle_move(delta)
			
func handle_move(delta: float):
	if body.position != target_pos:
		moving.emit()
		body.position = body.position.move_toward(target_pos, delta * speed)
		
	else:
		if !initial_facing:
			initial_facing = facing

		face(initial_facing)
		state = GridControllerState.Idle
		finished_moving.emit()

# ====== Public API ======
func move_to(pos: Vector2):
	if state == GridControllerState.Idle:
		target_pos = pos
		face_toward(target_pos)
		state = GridControllerState.Moving

func move_in(direction: Vector2):
	var next_position = body.position + direction * move_by
	move_to(next_position)
	
func get_movement_direction() -> Vector2:
	if state == GridControllerState.Idle:
		if Input.is_action_pressed("ui_up"):
			return Vector2.UP
		if Input.is_action_pressed("ui_right"):
			return Vector2.RIGHT
		if Input.is_action_pressed("ui_down"):
			return Vector2.DOWN
		if Input.is_action_pressed("ui_left"):
			return Vector2.LEFT
	return Vector2.ZERO

func face(dir: Constants.Facing) -> void:
	facing = dir

func face_toward(pos: Vector2) -> void:
	if pos.x > body.position.x:
		face(Constants.Facing.Right)
	elif pos.x < body.position.x:
		face(Constants.Facing.Left)

func about_face() -> void:
	match facing:
		Constants.Facing.Right:
			facing = Constants.Facing.Left
		Constants.Facing.Left:
			facing = Constants.Facing.Right
