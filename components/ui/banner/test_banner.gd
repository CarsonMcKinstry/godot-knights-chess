extends Control

@onready var banner_template = preload("res://components/ui/banner/banner.tscn")

var banner: Banner

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if banner == null || !banner.opened:
		if Input.is_action_just_pressed("ui_accept"):
			banner = banner_template.instantiate()
			banner.set_message("Hello World")
			banner.set_banner_type(Banner.BANNER_WITH_TIMEOUT_WITH_RESET)
			add_child(banner)
			
			await banner.open()
			
			await banner.finished_exiting
			print("banner finished exiting...")
