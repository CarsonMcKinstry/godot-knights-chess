extends Node

@onready var banner_template = preload("res://components/ui/banner/info_banner.tscn")

var banner: InfoBanner

func display_banner(
	target_control: Control,
	message: String
):
	if banner == null:
		banner = banner_template.instantiate()
		banner\
			.with_enter_speed(5)\
			.with_exit_speed(5)\
			.with_message(message)
		target_control.add_child(banner)
		banner.enter()
		await banner.entered

func close_banner():
	if banner != null && banner.state == InfoBanner.BannerState.Open:
		banner.exit()
		await banner.exited
		
		banner.queue_free()
