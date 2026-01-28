extends MarginContainer

@onready var button_back: TextureButton = $MarginContainer/VBoxContainer/ButtonBack

func _ready() -> void:
	button_back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UIStuff/main-menu.tscn")
