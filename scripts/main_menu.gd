extends MarginContainer

@onready var button_start: TextureButton = $MarginContainer/VBoxContainer/VBoxContainer/ButtonStart
@onready var button_scores: TextureButton = $MarginContainer/VBoxContainer/VBoxContainer/ButtonScores

func _ready() -> void:
	button_start.pressed.connect(_on_start_pressed)
	button_scores.pressed.connect(_on_scores_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UIStuff/name-selection.tscn")

func _on_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UIStuff/Scores.tscn")
