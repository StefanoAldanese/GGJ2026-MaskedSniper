extends CharacterBody3D

const MOUSE_SENS = 0.002
const NORMAL_FOV = 70.0
const ZOOM_FOV = 20.0
const ZOOM_SPEED = 5.0  # how fast camera zooms
const MOVEMENT_LIMIT_V = 0.4
const MOVEMENT_LIMIT_H = 0.4

var pitch := 0.0
var yaw := 0.0


@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = NORMAL_FOV

func _input(event):
	if event is InputEventMouseMotion:
		# Yaw (body)
		yaw -= event.relative.x * MOUSE_SENS
		yaw = clamp(yaw, -MOVEMENT_LIMIT_H, MOVEMENT_LIMIT_H) # 0.4 is the radian max movemnt
		rotation.y = yaw

		# Pitch (head)
		pitch -= event.relative.y * MOUSE_SENS
		pitch = clamp(pitch, -MOVEMENT_LIMIT_V, MOVEMENT_LIMIT_V)
		head.rotation.x = pitch

func _process(delta):
	# Check right mouse button
	var zooming = Input.is_action_pressed("aim")  #  "aim" mapped to Right Mouse Button
	var target_fov = ZOOM_FOV if zooming else NORMAL_FOV
	# Smoothly interpolate camera FOV
	camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	 # or camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
