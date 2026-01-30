extends VBoxContainer

@export var section_title: String = "Section Name"
@export var section_text: String = "Section Contents"

@onready var section_name: Label = $"Section Name"
@onready var section_contents: Label = $"Section Contents"

func _ready() -> void:
	section_name.text = section_title
	section_contents.text = section_text
