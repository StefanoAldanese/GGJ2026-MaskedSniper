extends CharacterBody3D

const MOUSE_SENS = 0.002
const NORMAL_FOV = 70.0
const ZOOM_FOV = 20.0
const ZOOM_SPEED = 5.0  # how fast camera zoomsù

var yaw_limit_min = 0
var pitch_limit_min = 0
var yaw_limit_max = 0
var pitch_limit_max = 0

var pitch := 0.0
var yaw := 0.0
var yaw_offset := 0.0
var pitch_offset := 0.0

var sniper_nests: Array[Node3D] = []
var current_nest_index := 0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func set_sniper_nests(nests: Array):
	sniper_nests = nests
	yaw_limit_min = sniper_nests[0].pitch_min
	pitch_limit_min = sniper_nests[0].yaw_min
	yaw_limit_max = sniper_nests[0].pitch_max
	pitch_limit_max = sniper_nests[0].yaw_max

func teleport_to_next_nest():
	if sniper_nests.is_empty():
		return

	current_nest_index = (current_nest_index + 1) % sniper_nests.size()
	var target = sniper_nests[current_nest_index]

	yaw_limit_min = target.pitch_min
	pitch_limit_min = target.yaw_min
	yaw_limit_max = target.pitch_max
	pitch_limit_max = target.yaw_max
	velocity = Vector3.ZERO
	global_position = target.global_position

	# Capture nest rotation
	var euler = target.global_transform.basis.get_euler()
	# Set offsets
	yaw_offset = euler.y
	pitch_offset = clamp(euler.x, -pitch_limit_min, 0)

	# Immediately apply rotation
	rotation.y = yaw_offset
	head.rotation.x = pitch_offset

	# Reset current yaw/pitch input to zero
	yaw = 0
	pitch = 0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = NORMAL_FOV

func _input(event):
	if event is InputEventMouseMotion:
		# Horizontal (body)
		yaw += -event.relative.x * MOUSE_SENS
		rotation.y = clamp(yaw + yaw_offset, -yaw_limit_min + yaw_offset, yaw_limit_max + yaw_offset)

		# Vertical (head)
		pitch += -event.relative.y * MOUSE_SENS
		head.rotation.x = clamp(pitch + pitch_offset, -pitch_limit_min + pitch_offset, pitch_limit_max + pitch_offset)



func _process(delta):
	# Check right mouse button
	var zooming = Input.is_action_pressed("aim")  #  "aim" mapped to Right Mouse Button
	var target_fov = ZOOM_FOV if zooming else NORMAL_FOV
	# Smoothly interpolate camera FOV
	camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	 # or camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	
	# Teleport
	if Input.is_action_just_pressed("teleport"):
		teleport_to_next_nest()
