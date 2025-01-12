class_name Banner extends Control

const BANNER_PERSIST = 0
const BANNER_WITH_TIMEOUT_WITH_RESET = 1
const BANNER_WITH_TIMEOUT_WITHOUT_RESET = 2


signal finished_opening
signal finished_exiting

@export var disappear_after: float = 5.0
@export var fade_time: float = 0.15

@export var label: Label

var opened: bool = false
var timer: SceneTreeTimer
var banner_type: int = 1

func _process(delta):
	match banner_type:
		BANNER_WITH_TIMEOUT_WITHOUT_RESET:
			if timer != null:
				if Input.is_action_just_pressed("ui_cancel"):
					timer.time_left = 0
		BANNER_WITH_TIMEOUT_WITH_RESET:
			if timer != null:
				if Input.is_action_just_pressed("ui_accept"):
					timer.time_left = disappear_after
				elif Input.is_action_just_pressed("ui_cancel"):
					timer.time_left = 0

func set_message(message: String) -> Banner:
	label.text = message
	return self

func set_timeout(timeout: float) -> Banner:
	disappear_after = timeout
	return self

func set_fade_time(i_fade_time: float) -> Banner:
	fade_time = i_fade_time
	return self
	
func set_banner_type(i_banner_type: int) -> Banner:
	banner_type = i_banner_type
	return self

func open() -> void:
	await fade_in()
	opened = true
	finished_opening.emit()
	_on_opening_finished()

func close() -> void:
	await fade_out()
	opened = false
	finished_exiting.emit()
	queue_free()

func _on_opening_finished():

	match banner_type:
		BANNER_PERSIST:
			on_persist()
		BANNER_WITH_TIMEOUT_WITHOUT_RESET:
			start_timer()
		BANNER_WITH_TIMEOUT_WITH_RESET:
			start_timer()
	
	pass

func on_persist() -> void:
	await _get_timer().timeout
	close()

func start_timer() -> void:
	timer = _get_timer()
	
	await timer.timeout
	
	close()

func fade_in() -> void:
	var tween = _get_tween()
	
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	await tween.finished

func fade_out() -> void:
	var tween = _get_tween()
	
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	await tween.finished

func _get_tween() -> Tween:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	return tween

func _get_timer() -> SceneTreeTimer:
	var timer = get_tree().create_timer(disappear_after)
	return timer
