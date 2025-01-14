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
var dismiss_time: float = 0
var timer: SceneTreeTimer

var behavior: int = BANNER_BEHAVIOR_PERSIST

func _process(_delta):
	if state == BannerState.Open:
		match behavior:
			BANNER_BEHAVIOR_PERSIST:
				_check_for_close("ui_accept")
			BANNER_BEHAVIOR_TIMER:
				_check_for_timer_reset()
			BANNER_BEHABIOR_TIMER_CANCELABLE:
				_check_for_timer_reset()
				_check_for_timer_cancel()

func _check_for_close(action: String = "ui_cancel"):
	if Input.is_action_just_pressed(action):
		close_banner()

func _check_for_timer_reset(action: String = "ui_accept"):
	if Input.is_action_just_pressed(action):
		_reset_timer()
		
func _check_for_timer_cancel(action: String = "ui_cancel"):
	if Input.is_action_just_pressed(action):
		_cancel_timer()

func _start_timer():
	if timer == null:
		timer = get_tree().create_timer(dismiss_time)

func _cancel_timer():
	if timer != null:
		timer.time_left = 0

func _reset_timer():
	if timer != null:
		timer.time_left = dismiss_time

func _start_behavior():
	match behavior:
		BANNER_BEHABIOR_TIMER_CANCELABLE:
			_start_timer()
		BANNER_BEHAVIOR_TIMER:
			_start_timer()
			
	if timer != null:
		timer.connect("timeout", close_banner, CONNECT_ONE_SHOT)

func display_banner(
	target_control: Control,
	message: String,
	i_behavior: int = BANNER_BEHAVIOR_PERSIST,
	i_dismiss_time: float = 0.0
):
	behavior = i_behavior	
	dismiss_time = i_dismiss_time
	if state == BannerState.Closed:
		state = BannerState.Opening
		banner = banner_template.instantiate()
		banner\
			.with_enter_speed(.15)\
			.with_exit_speed(.1)\
			.with_message(message)
		target_control.add_child(banner)
		banner.enter()
		_start_behavior()
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
		
