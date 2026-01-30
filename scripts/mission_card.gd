extends Control
@onready var mission_number: Label = $"TextureRect/MarginContainer/VBoxContainer/HBoxContainer/mission number"
@export var numero_missione: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mission_number.text = str(PlayerData.current_day)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
