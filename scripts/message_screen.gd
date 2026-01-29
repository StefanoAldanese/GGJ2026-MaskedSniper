extends PanelContainer

@onready var label: Label = $Label

@export var testo: String = "Ciao"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = testo
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
