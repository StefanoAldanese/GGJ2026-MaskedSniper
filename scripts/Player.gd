extends CharacterBody3D

const MOUSE_SENS = 0.002
const NORMAL_FOV = 70.0
const ZOOM_FOV = 20.0
const ZOOM_SPEED = 5.0  # how fast camera zooms

const BAR_WIDTH_PERCENT = 0.20

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
@onready var shoot_ray: RayCast3D = $Head/Camera3D/RayCast3D

@onready var left_bar: ColorRect = $Head/Camera3D/SniperUI/LeftBar
@onready var right_bar: ColorRect = $Head/Camera3D/SniperUI/RightBar

func set_sniper_nests(nests: Array):
	sniper_nests = nests
	# set starting limits based on first nest's
	yaw_limit_min = sniper_nests[0].pitch_min
	pitch_limit_min = sniper_nests[0].yaw_min
	yaw_limit_max = sniper_nests[0].pitch_max
	pitch_limit_max = sniper_nests[0].yaw_max

func teleport_to_next_nest():
	if sniper_nests.is_empty():
		return

	current_nest_index = (current_nest_index + 1) % sniper_nests.size()
	var target = sniper_nests[current_nest_index]

	# set limits after teleport --> unique to nest
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

func shoot() -> void:
	print("I'm shooting")
	if shoot_ray.is_colliding():
		var collider = shoot_ray.get_collider()
		if collider is Area3D and collider.has_method("die"):
			collider.die()

			
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
	
	if event.is_action_pressed("shoot"):
		shoot()

func _process(delta):
	# Check right mouse button
	var zooming = Input.is_action_pressed("aim")
	var target_fov = ZOOM_FOV if zooming else NORMAL_FOV
	
	# Smoothly interpolate camera FOV (codice esistente)
	camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	
	# --- C. NUOVO CODICE PER LE BANDE NERE ---
	# 1. Calcoliamo la larghezza target dello schermo
	var viewport_width = get_viewport().get_visible_rect().size.x
	var target_bar_width = 0.0
	
	# Se stiamo mirando, la larghezza target è il 20% dello schermo, altrimenti è 0
	if zooming:
		target_bar_width = viewport_width * BAR_WIDTH_PERCENT
	
	# 2. Interpoliamo (animiamo) la larghezza attuale verso il target
	var current_width = left_bar.size.x
	var new_width = lerp(current_width, target_bar_width, delta * ZOOM_SPEED)
	
	# 3. Applichiamo la nuova larghezza alla barra Sinistra
	left_bar.size.x = new_width
	left_bar.position.x = 0 # Sempre ancorata a sinistra
	
	# 4. Applichiamo la nuova larghezza alla barra Destra
	right_bar.size.x = new_width
	# La barra destra deve spostarsi per rimanere ancorata al bordo destro
	right_bar.position.x = viewport_width - new_width
	
	
	# Teleport (codice esistente)
	if Input.is_action_just_pressed("teleport"):
		teleport_to_next_nest()
		
		
