class_name InfoBanner extends CenterContainer

signal entered
signal exited

@export var background_rect: NinePatchRect
@export var label: Label

@export var enter_speed: float = 0.15
@export var exit_speed: float = 0.1

@onready var initial_size: Vector2 = background_rect.custom_minimum_size

enum BannerState {
	Closed,
	Closing,
	Opening,
	Open
}

var state: BannerState = BannerState.Closed

func _ready():
	hide()
	label.hide()
	background_rect.custom_minimum_size = Vector2.ZERO

func with_message(message: String) -> InfoBanner:
	label.text = message
	return self

func with_enter_speed(i_enter_speed: float) -> InfoBanner:
	enter_speed = i_enter_speed
	return self
	
func with_exit_speed(i_exit_speed: float) -> InfoBanner:
	exit_speed = i_exit_speed
	return self

func enter():
	state = BannerState.Opening
	show()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(
		background_rect,
		"custom_minimum_size",
		initial_size,
		enter_speed
	)
	
	await tween.finished
	
	label.show()
	state = BannerState.Open
	entered.emit()
	
func exit():
	state = BannerState.Closing
	label.hide()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(
		background_rect,
		"custom_minimum_size",
		Vector2.ZERO,
		exit_speed
	)
	await tween.finished
	hide()
	state = BannerState.Closed
	exited.emit()
