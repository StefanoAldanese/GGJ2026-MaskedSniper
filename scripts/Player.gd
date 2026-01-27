extends CharacterBody3D

const MOUSE_SENS = 0.002
const NORMAL_FOV = 70.0
const ZOOM_FOV = 20.0
const ZOOM_SPEED = 5.0  # how fast camera zooms

const NOTEPAD_SPEED = 8.0

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

var msg_tween: Tween

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var shoot_ray: RayCast3D = $Head/Camera3D/RayCast3D

@onready var notepad: Node3D = $Head/Camera3D/Notepad
@onready var console_msg: Label = $Head/Camera3D/SniperUI/MessageHolder/ConsoleMsg

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
	if shoot_ray.is_colliding():
		var collider = shoot_ray.get_collider()
		
		# Controlliamo se è un nemico e se ha la funzione die
		if collider is Area3D and collider.has_method("die"):
			
			# -- NUOVA LOGICA MESSAGGI --
			# Verifichiamo se è il target (leggendo la variabile dal nemico)
			if "is_target" in collider:
				if collider.is_target:
					# Messaggio vittoria
					print_console_message("STATUS: BAROQUE 2\nBERSAGLIO ELIMINATO", 5.0)
				else:
					# Messaggio errore
					print_console_message("STATUS: WRONG\n ARCHANGEL IS DISAPPOINTED", 5.0)
			
			# Procediamo con l'eliminazione
			collider.die()

			
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = NORMAL_FOV
	if notepad:
		notepad.visible = true
		notepad_visible_pos = notepad.position
		notepad_hidden_pos = notepad_visible_pos - Vector3(0, 0.8, 0)
		notepad.position = notepad_hidden_pos
	
	if console_msg:
		console_msg.text = ""

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

func toggle_notepad():
	if notepad:
		notepad.visible = !notepad.visible

func receive_target_list(targets: Array):
	# Passiamo i dati al nodo Notepad che aggiornerà la Label3D
	if notepad and notepad.has_method("update_target_info"):
		notepad.update_target_info(targets)
	else:
		print("Errore: Nodo Notepad non trovato o script mancante!")


func print_console_message(text_content: String, duration: float = 3.0):
	if not console_msg: return
	
	# 1. Se c'è già un messaggio che sta scrivendo, lo interrompiamo
	if msg_tween:
		msg_tween.kill()
	
	# 2. Impostiamo il testo e lo rendiamo invisibile (0 caratteri mostrati)
	console_msg.text = text_content
	console_msg.visible_ratio = 0.0 # Nasconde tutto il testo
	console_msg.modulate.a = 1.0    # Assicura che sia opaco (visibile)
	
	# 3. Creiamo l'animazione (Tween)
	msg_tween = create_tween()
	
	# A. Effetto Macchina da scrivere (da 0% a 100% visibile)
	# Calcoliamo la velocità: 0.05 secondi per ogni lettera
	var typing_speed = text_content.length() * 0.05 
	msg_tween.tween_property(console_msg, "visible_ratio", 1.0, typing_speed)
	
	# B. Pausa per leggere (duration)
	msg_tween.tween_interval(duration)
	
	# C. Dissolvenza finale (Fade out)
	msg_tween.tween_property(console_msg, "modulate:a", 0.0, 1.0)
	
	# D. Pulizia finale
	msg_tween.tween_callback(func(): console_msg.text = "")



func _process(delta):
	# Check right mouse button
	var zooming = Input.is_action_pressed("aim")
	var target_fov = ZOOM_FOV if zooming else NORMAL_FOV
	
	# Smoothly interpolate camera FOV (codice esistente)
	camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	
	# --- ANIMAZIONE NOTEPAD (Hold Space) ---
	if notepad:
		var target_pos = notepad_hidden_pos
		
		# Se tengo premuto SPAZIO ("ui_accept"), il target diventa la posizione alta
		if Input.is_action_pressed("ui_accept"):
			target_pos = notepad_visible_pos
		
		# Muoviamo gradualmente il notepad verso il target
		notepad.position = notepad.position.lerp(target_pos, delta * NOTEPAD_SPEED)
	
	# Teleport (codice esistente)
	if Input.is_action_just_pressed("teleport"):
		teleport_to_next_nest()
		

		
		
