extends PanelContainer

@onready var label: Label = $ColorRect/VBoxContainer/Label
@onready var score_label: Label = $"ColorRect/VBoxContainer/HBoxContainer/score number"

@export var testo: String = "Ciao"
@export var score_testo: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = testo
	score_label.text = str(PlayerData.current_score +100)
	pass # Replace with function body.
