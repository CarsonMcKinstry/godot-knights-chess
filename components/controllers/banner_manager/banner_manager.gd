extends Node

signal entered
signal exited

@onready var banner_template = preload("res://components/ui/banner/info_banner.tscn")

var banner: InfoBanner

const BANNER_BEHAVIOR_PERSIST = 0
const BANNER_BEHAVIOR_TIMER = 1
const BANNER_BEHABIOR_TIMER_CANCELABLE = 2

enum BannerState {
	Open,
	Opening,
	Closed,
	Closing
}

var state: BannerState = BannerState.Closed
var behavior: int = BANNER_BEHAVIOR_PERSIST

func _process(_delta):
	if state == BannerState.Open:
		if Input.is_action_just_pressed("ui_accept"):
			close_banner()

func _handle_persist():
	pass

func _handle_timer():
	pass

func _handle_timer_cancelable():
	pass

func display_banner(
	target_control: Control,
	message: String,
	i_behavior: int
):
	behavior = i_behavior
	if state == BannerState.Closed:
		state = BannerState.Opening
		banner = banner_template.instantiate()
		banner\
			.with_enter_speed(5)\
			.with_exit_speed(5)\
			.with_message(message)
		target_control.add_child(banner)
		banner.enter()
		await banner.entered
		entered.emit()
		state = BannerState.Open

func close_banner():
	if banner != null && state == BannerState.Open:
		state = BannerState.Closing
		banner.exit()
		await banner.exited
		
		banner.queue_free()
		exited.emit()
		state = BannerState.Closed
		
