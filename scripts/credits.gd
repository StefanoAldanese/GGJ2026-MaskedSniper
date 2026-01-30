extends Node
@onready var texture_button: TextureButton = $TextureRect/MarginContainer/TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UIStuff/main-menu.tscn")
