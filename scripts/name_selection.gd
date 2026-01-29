extends MarginContainer

@onready var button_yes: TextureButton = $"MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/Button YES"
@onready var button_no: TextureButton = $"MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/Button NO"
@onready var line_edit: LineEdit = $MarginContainer/VBoxContainer/LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_yes.pressed.connect(_on_yes_pressed)
	button_no.pressed.connect(_on_no_pressed)

func _on_yes_pressed() -> void:
	var name := line_edit.text.strip_edges()
	if name.is_empty() == false:
		PlayerData.current_nickname = name
		PlayerData.current_score = 0
		PlayerData.current_day = 1
		get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_no_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UIStuff/main-menu.tscn")
