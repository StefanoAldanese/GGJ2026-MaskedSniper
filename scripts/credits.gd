extends Control

@export var scroll_speed := 30.0  # pixels per second
@onready var scroll_container: ScrollContainer = $MarginContainer/ScrollContainer

func _ready():
	set_process(false)
	var max_scroll = scroll_container.get_v_scroll_bar().max_value
	print(max_scroll)
	scroll_container.scroll_vertical = 0
	await get_tree().create_timer(1.5).timeout
	set_process(true) 
	
func _process(delta):
	var max_scroll = scroll_container.get_v_scroll_bar().max_value
	if scroll_container.scroll_vertical < max_scroll:
		scroll_container.scroll_vertical += scroll_speed * delta
