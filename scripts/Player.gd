extends CharacterBody3D

const MOUSE_SENS = 0.002
var pitch := 0.0

@onready var head: Node3D = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS)

		pitch -= event.relative.y * MOUSE_SENS
		pitch = clamp(pitch, -1.4, 1.4)
		$Head.rotation.x = pitch
