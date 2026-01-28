extends CharacterBody3D

const MOUSE_SENS = 0.002
const NORMAL_FOV = 70.0
const ZOOM_FOV = 20.0
const ZOOM_SPEED = 5.0  # how fast camera zooms

const NOTEPAD_SPEED = 10.0

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

var notepad_visible_pos: Vector3
var notepad_hidden_pos: Vector3

var random_hour_start: float = 0.0

# --- RIFERIMENTI AI NODI ---
# --- RIFERIMENTI AI NODI ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var shoot_ray: RayCast3D = $Head/Camera3D/RayCast3D

# Riferimenti al ToolContainer e Orologio
@onready var tool_container: Node3D = $Head/Camera3D/ToolContainer
@onready var notepad: Node3D = $Head/Camera3D/ToolContainer/Notepad
@onready var clock: Node3D = $Head/Camera3D/ToolContainer/Clock      

# Riferimento dinamico alla lancetta (usa il nome esatto che mi hai dato)
# Assumiamo che "Clock" sia il nodo padre che contiene le mesh importate
@onready var clock_hand_long: MeshInstance3D = $Head/Camera3D/ToolContainer/Clock/orologio/lancetta_lunga_geo
@onready var clock_hand_short: MeshInstance3D = $Head/Camera3D/ToolContainer/Clock/orologio/lancetta_corta_geo

# --- VARIABILI TIMER ---
@export var kill_timer_limit: float = 90.0 
var current_timer_value: float = 0.0

var container_visible_pos: Vector3
var container_hidden_pos: Vector3

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
		print(collider)
		if collider is CharacterBody3D and collider.has_method("die"):
			collider.die()
			

			
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = NORMAL_FOV
	
	if tool_container:
		# 1. Forza la visibilità su tutto
		tool_container.visible = true
		if notepad: notepad.visible = true
		if clock: clock.visible = true # O usa il riferimento al padre dell'orologio
		
		# 2. Salva la posizione "SU" (quella che hai impostato nell'editor)
		container_visible_pos = tool_container.position
		
		# 3. Calcola la posizione "GIÙ" e nascondilo subito
		container_hidden_pos = container_visible_pos - Vector3(0, 1.2, 0) 
		tool_container.position = container_hidden_pos
		
	# --- RANDOMIZZAZIONE ORA ---
	random_hour_start = randf_range(0.0, 360.0)
	if clock_hand_short:
		clock_hand_short.rotation_degrees.y = random_hour_start
		  
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
		
	if event.is_action_pressed("restart_scene"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("teleport"):
		teleport_to_next_nest()
	

func toggle_notepad():
	if notepad:
		notepad.visible = !notepad.visible

func receive_target_list(targets: Array):
	# Passiamo i dati al nodo Notepad che aggiornerà la Label3D
	if notepad and notepad.has_method("update_target_info"):
		notepad.update_target_info(targets)
	else:
		print("Errore: Nodo Notepad non trovato o script mancante!")

func _process(delta):
	# --- LOGICA TIMER E LANCETTE ---
	if current_timer_value < kill_timer_limit:
		current_timer_value += delta
		
		# Calcolo rotazione (360 gradi * percentuale tempo trascorso)
		var progress = current_timer_value / kill_timer_limit
		var rotation_angle = progress * -360.0 # Segno meno per senso orario
		
		if clock_hand_long:
		# Assicurati che l'asse di rotazione sia quello giusto (solitamente Z o Y)
			clock_hand_long.rotation_degrees.y = rotation_angle
		
		if clock_hand_short:
		# Si muove a 1/12 della velocità dei minuti
			clock_hand_short.rotation_degrees.y = rotation_angle / 12.0
		
		# 2. Lancetta Ore (Randomizzata + Movimento lento)
		if clock_hand_short:
			# Parte dall'ora casuale (random_hour_start)
			# E si muove di 1/12 rispetto ai minuti
			clock_hand_short.rotation_degrees.y = random_hour_start + (rotation_angle / 12.0)
			
		if current_timer_value >= kill_timer_limit:
			_on_time_expired()
			
		

	# --- ANIMAZIONE TOOLS (Salita/Discesa) ---
	var target_fov = ZOOM_FOV if Input.is_action_pressed("aim") else NORMAL_FOV
	camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	
	if tool_container:
		var target_pos = container_hidden_pos
		if Input.is_action_pressed("notepad"): # Se tieni premuto Spazio
			target_pos = container_visible_pos
		
		tool_container.position = tool_container.position.lerp(target_pos, delta * NOTEPAD_SPEED)

func _on_time_expired():
	print("TEMPO SCADUTO! Il target è fuggito.")
	# Aggiungi qui la logica di sconfitta
