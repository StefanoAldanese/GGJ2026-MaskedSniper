extends Node3D

@onready var bg: TextureRect = $TextureRect
@export var images: Array[Texture2D]

func _ready():
	randomize()
	if images.is_empty():
		push_warning("No images assigned!")
		return

	bg.texture = images.pick_random()
