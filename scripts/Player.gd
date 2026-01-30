extends CharacterBody3D

const MOUSE_SENS = 0.002
const NORMAL_FOV = 70.0
const ZOOM_FOV = 5.0
const ZOOM_SPEED = 5.0
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
var normal_material: StandardMaterial3D = null
var panic_material: StandardMaterial3D = null

var teleport_hold_time: float = 0.0
const TELEPORT_REQUIRED_TIME: float = 1
var is_teleporting: bool = false
var teleport_cooldown: float = 0.0
const TELEPORT_COOLDOWN_TIME: float = 0.5 # Mezzo secondo di blocco

# --- RIFERIMENTI AI NODI ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var shoot_ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var tool_container: Node3D = $Head/Camera3D/ToolContainer
@onready var notepad: Node3D = $Head/Camera3D/ToolContainer/Notepad
@onready var clock: Node3D = $Head/Camera3D/ToolContainer/Clock      
@onready var clock_hand_long: MeshInstance3D = $Head/Camera3D/ToolContainer/Clock/orologio/lancetta_lunga_geo
@onready var clock_hand_short: MeshInstance3D = $Head/Camera3D/ToolContainer/Clock/orologio/lancetta_corta_geo
@onready var sniper_camera: Camera3D = $Head/Camera3D/SubViewportContainer/SubViewport/SniperCamera

@onready var lens_camera: Camera3D = $Head/Camera3D/ScopeViewport/LensCamera
@onready var scope_viewport: SubViewport = $Head/Camera3D/ScopeViewport
@onready var enemies_container = get_tree().root.find_child("Enemies", true, false)

@onready var curtain_left: ColorRect = ColorRect.new()
@onready var curtain_right: ColorRect = ColorRect.new()
# --- VARIABILI TIMER ---
@export var kill_timer_limit: float = 90.0 
@onready var shoot_sound: AudioStreamPlayer3D = $Head/ShootSound
@onready var tools_sound: AudioStreamPlayer3D = $Head/swoosh
@onready var police_siren = get_tree().root.find_child("police_siren", true, false)
@onready var chattering = get_tree().root.find_child("chattering", true, false)
@onready var panic_sound = get_tree().root.find_child("panic", true, false)

# DEFINIAMO LA DURATA TOTALE DEL PANICO QUI
const PANIC_DURATION: float = 30.0 
var panic_timer: float = 0.0 

var current_timer_value: float = 0.0

var container_visible_pos: Vector3
var container_hidden_pos: Vector3

var max_ammo: int = 2
var current_ammo: int = 2
var is_game_over: bool = false
var is_panic_mode: bool = false

var is_aiming: bool = false

# UI BULLET
var bullet_ui_blue: TextureRect
var bullet_ui_red: TextureRect

var last_tool_state: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = NORMAL_FOV
	
	$Head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	chattering.play()
	# Setup Tende (Curtains)
	for c in [curtain_left, curtain_right]:
		add_child(c)
		c.color = Color.BLACK
		c.anchor_bottom = 1.0
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Assicuriamoci che siano sopra tutto il resto nella UI
		c.z_index = 10 
	
	# Posizione iniziale (fuori schermo)
	_update_curtains(0.0)
	
	# Aspettiamo un frame per essere sicuri che il Viewport sia inizializzato
	await get_tree().process_frame
	
	if scope_viewport and sniper_camera:
		# Otteniamo la texture dinamica dal viewport
		var scope_texture = scope_viewport.get_texture()
		
		# Chiamiamo la funzione che abbiamo appena scritto nell'altro script
		if sniper_camera.has_method("setup_scope_material"):
			sniper_camera.setup_scope_material(scope_texture)
			
	
	# Lancette Luminose rosse in panicMode
	panic_material = StandardMaterial3D.new()
	panic_material.albedo_color = Color.RED
	panic_material.emission_enabled = true
	panic_material.emission = Color.RED
	panic_material.emission_energy_multiplier = 2.0
	
	if tool_container:
		tool_container.visible = true
		if notepad: notepad.visible = true
		if clock: clock.visible = true
		
		container_visible_pos = tool_container.position
		container_hidden_pos = container_visible_pos - Vector3(0, 1.2, 0) 
		tool_container.position = container_hidden_pos
		
	# --- RANDOMIZZAZIONE ORA ---
	random_hour_start = randf_range(0.0, 360.0)
	# Impostiamo l'orologio a zero all'avvio
	update_clock_hands(0.0)
	
func _physics_process(delta):
	# Keep the Sniper Camera (the weapon model) following your head
	$Head/Camera3D/SubViewportContainer/SubViewport/SniperCamera.global_transform = camera.global_transform
	
	if lens_camera and sniper_camera and sniper_camera.sniper_scope:
		# Match the zoom camera position to the physical "Lent" mesh
		lens_camera.global_position = sniper_camera.sniper_scope.global_position
		# Match the rotation to where you are actually looking
		lens_camera.global_transform.basis = camera.global_transform.basis

func _process(delta):
	if is_game_over: return

	# --- GESTIONE AIMING E ANIMAZIONI SCOPE ---
	# Controlliamo se il giocatore sta premendo il tasto aim
	var aim_input = Input.is_action_pressed("aim")
	
	# Se lo stato è cambiato rispetto al frame precedente
	if aim_input != is_aiming:
		is_aiming = aim_input
		# Chiamiamo l'animazione sulla sniper_camera
		if sniper_camera.has_method("play_scope_anim"):
			sniper_camera.play_scope_anim(is_aiming)

	# LOGICA PIP:
	# 1. La camera principale (periferica) zooma solo leggermente o per nulla
	var main_target_fov = 50.0 if is_aiming else NORMAL_FOV 
	camera.fov = lerp(camera.fov, main_target_fov, delta * ZOOM_SPEED)
	
	# 2. La camera interna alla lente (LensCamera) ha il vero zoom (es. 10 o 20 FOV)
	if lens_camera:
		var scope_target_fov = ZOOM_FOV # (es. 20.0 definito nelle costanti )
		# Quando non miri, tieni il FOV della lente normale per evitare distorsioni strane se guardi il fucile
		if not is_aiming: scope_target_fov = NORMAL_FOV 
		
		lens_camera.fov = lerp(lens_camera.fov, scope_target_fov, delta * ZOOM_SPEED)
		
	#Deprecated!!!!!
	# ar target_fov = ZOOM_FOV if is_aiming else NORMAL_FOV
	# camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)
	
# --- LOGICA TELEPORT CON TENDE ---

# Gestione del cooldown (scorre sempre se maggiore di 0)
	if teleport_cooldown > 0:
		teleport_cooldown -= delta

	# --- LOGICA TELEPORT CON TENDE ---
	var teleport_input = Input.is_action_pressed("teleport")
	
	# Aggiungiamo "teleport_cooldown <= 0" alla condizione
	if teleport_input and not is_aiming and teleport_cooldown <= 0:
		is_teleporting = true
		teleport_hold_time += delta
		
		var progress = clamp(teleport_hold_time / TELEPORT_REQUIRED_TIME, 0.0, 1.0)
		_update_curtains(progress)
		
		if teleport_hold_time >= TELEPORT_REQUIRED_TIME:
			teleport_to_next_nest()
			teleport_hold_time = 0.0
			teleport_cooldown = TELEPORT_COOLDOWN_TIME # ATTIVA IL COOLDOWN QUI
	else:
		# Se il tasto viene rilasciato O se siamo in cooldown dopo un salto
		is_teleporting = false # Forza lo stato a false così puoi sparare/usare il taccuino
		teleport_hold_time = move_toward(teleport_hold_time, 0.0, delta * 2.0)
		var progress = clamp(teleport_hold_time / TELEPORT_REQUIRED_TIME, 0.0, 1.0)
		_update_curtains(progress)
		
		# Stato is_teleporting finché le tende non sono quasi del tutto aperte
		if teleport_hold_time <= 0.1:
			is_teleporting = false
	# --- BLOCCO AZIONI ---
	# Modifica la condizione del notepad per includere "and not is_teleporting"
	var is_notepad_req = Input.is_action_pressed("notepad")
	var should_show_tools = is_notepad_req and not is_aiming and not is_teleporting
	var is_holding_f = Input.is_key_pressed(KEY_F)
	
	
	# PLAY SOUND ONLY ON CHANGE
	if should_show_tools != last_tool_state:
		tools_sound.play()
		last_tool_state = should_show_tools
		
	# Il taccuino si apre SOLO se richiesto E NON stiamo mirando
	
	if sniper_camera and sniper_camera.has_method("set_lowered"):
		# Abbassa il fucile se stiamo guardando il taccuino o tenendo premuto F
		sniper_camera.set_lowered(should_show_tools or is_holding_f)
	
	if tool_container:
		var target_pos = container_hidden_pos
		if should_show_tools:
			target_pos = container_visible_pos
		tool_container.position = tool_container.position.lerp(target_pos, delta * NOTEPAD_SPEED)
		
	# --- LOGICA TEMPO E OROLOGIO ---
	if is_panic_mode:
		_process_panic_mode(delta)
	else:
		_process_normal_mode(delta)


# --- LOGICA PANIC MODE (SOLO EFFETTO VISIVO) ---
func _process_panic_mode(delta):
	# Il timer scorre matematicamente per il Game Over...
	panic_timer -= delta
	
	#L'orologio NON lo traccia più. Impazzisce.
	
	# Velocità di rotazione (Gradi al secondo)
	# 720 gradi = 2 giri completi al secondo
	# 1080 gradi = 3 giri completi al secondo
	
	if clock_hand_long:
		# La lancetta dei minuti gira velocissima
		clock_hand_long.rotation_degrees.y += 1080.0 * delta
		
	if clock_hand_short:
		# Anche quella delle ore gira veloce (ma magari un po' meno per differenziarle)
		clock_hand_short.rotation_degrees.y -= 720.0 * delta

	# Controllo Game Over
	if panic_timer <= 0:
		if not is_game_over:
			print("GAME OVER: 30 secondi scaduti dopo aver ucciso un civile!")
			emit_signal("i_lost")
			is_game_over = true

func _process_normal_mode(delta):
	current_timer_value += delta
	if current_timer_value < kill_timer_limit:
		var fraction = current_timer_value / kill_timer_limit
		update_clock_hands(fraction)
	else:
		_on_time_expired()

# Funzione unica per muovere le lancette
func update_clock_hands(progress_ratio: float):
	# Un giro completo = 360 gradi.
	var minutes_angle = progress_ratio * -360.0
	
	if clock_hand_long:
		clock_hand_long.rotation_degrees.y = minutes_angle
	
	if clock_hand_short:
		# Lancetta ore sincronizzata
		clock_hand_short.rotation_degrees.y = random_hour_start + (minutes_angle / 12.0)

func shoot() -> void:
	if is_game_over or is_teleporting: return # Bloccato se sta cambiando nido
	
	if current_ammo <= 0:
		print("Click! Munizioni esaurite.")
		return
	
	# --- ANIMAZIONE SPARO ---
	if sniper_camera.has_method("play_fire_anim"):
		sniper_camera.play_fire_anim(is_aiming)
	
	shoot_sound.play()
	
	current_ammo -= 1
	
	# --- UI PROIETTILI ---
	if current_ammo == 1 and bullet_ui_blue:
		bullet_ui_blue.visible = false
	elif current_ammo == 0 and bullet_ui_red:
		bullet_ui_red.visible = false
	
	print("Sparo! Munizioni rimanenti: ", current_ammo)
	
	if shoot_ray.is_colliding():
		var collider = shoot_ray.get_collider()
		# print(collider) # Decommenta per debug
		if collider is CharacterBody3D and collider.has_method("die"):
			var is_the_target = collider.get("is_target")
			collider.die()
			
			if is_the_target:
				_handle_victory()
			else:
				_handle_civilian_kill()
	else:
		_shot_missed()
	
	if current_ammo <= 0 and not is_game_over:
		print("GAME OVER: Munizioni finite senza colpire il bersaglio!")
		emit_signal("i_lost")
		is_game_over = true

func _handle_victory():
	print("VITTORIA! Bersaglio eliminato.")
	emit_signal("i_won")
	is_game_over = true



func _switch_to_panic_audio():
	if panic_sound:
		panic_sound.play()
		
	# --- POLICE SIREN LOGIC ---
	if police_siren:
		police_siren.play()
	
	# Tell enemies to run
	for enemy in enemies_container.get_children():
		enemy.go_into_panic()

func _handle_civilian_kill():
	if not is_panic_mode:
		print("Proiettile sprecato, gli invitato sono allertati!")
		_switch_to_panic_audio()
		is_panic_mode = true
		# Resettiamo il timer usando la COSTANTE
		panic_timer = PANIC_DURATION
		_apply_clock_color(true)

func _shot_missed():
	if not is_panic_mode:
		print("ATTENZIONE! Civile colpito. Hai 30 secondi per trovare il bersaglio vero!")
		_switch_to_panic_audio()
		is_panic_mode = true
		# Resettiamo il timer usando la COSTANTE
		panic_timer = PANIC_DURATION
		_apply_clock_color(true)

func _on_time_expired():
	print("TEMPO SCADUTO! Il target è fuggito.")
	emit_signal("i_lost")
	is_game_over = true
	

func _input(event):
	if event.is_action_pressed("restart_scene"):
		get_tree().reload_current_scene()
		
	if is_game_over: return

	if event is InputEventMouseMotion:
		yaw += -event.relative.x * MOUSE_SENS
		rotation.y = clamp(yaw + yaw_offset, -yaw_limit_min + yaw_offset, yaw_limit_max + yaw_offset)
		pitch += -event.relative.y * MOUSE_SENS
		head.rotation.x = clamp(pitch + pitch_offset, -pitch_limit_min + pitch_offset, pitch_limit_max + pitch_offset)
		sniper_camera.sway(Vector2(event.relative.x, event.relative.y))

	if event.is_action_pressed("shoot"):
		shoot()
		
func set_sniper_nests(nests: Array):
	sniper_nests = nests
	if sniper_nests.size() > 0:
		yaw_limit_min = sniper_nests[0].pitch_min
		pitch_limit_min = sniper_nests[0].yaw_min
		yaw_limit_max = sniper_nests[0].pitch_max
		pitch_limit_max = sniper_nests[0].yaw_max

func teleport_to_next_nest():
	if sniper_nests.is_empty(): return
	current_nest_index = (current_nest_index + 1) % sniper_nests.size()
	var target = sniper_nests[current_nest_index]
	
	yaw_limit_min = target.pitch_min
	pitch_limit_min = target.yaw_min
	yaw_limit_max = target.pitch_max
	pitch_limit_max = target.yaw_max
	
	velocity = Vector3.ZERO
	global_position = target.global_position

	var euler = target.global_transform.basis.get_euler()
	yaw_offset = euler.y
	pitch_offset = clamp(euler.x, -pitch_limit_min, 0)

	rotation.y = yaw_offset
	head.rotation.x = pitch_offset
	yaw = 0
	pitch = 0

func toggle_notepad():
	if notepad:
		notepad.visible = !notepad.visible

func receive_target_list(targets: Array):
	if notepad and notepad.has_method("update_target_info"):
		notepad.update_target_info(targets)

# Funzione di supporto per cambiare il colore
func _apply_clock_color(is_panic: bool):
	var mat = panic_material if is_panic else null # Null resetta al materiale originale
	if clock_hand_long:
		clock_hand_long.set_surface_override_material(0, mat)
	if clock_hand_short:
		clock_hand_short.set_surface_override_material(0, mat)
		
func _update_curtains(progress: float):
	var screen_width = get_viewport().get_visible_rect().size.x
	var curtain_width = (screen_width / 2.0) * progress
	
	curtain_left.size = Vector2(curtain_width, get_viewport().get_visible_rect().size.y)
	curtain_right.size = Vector2(curtain_width, get_viewport().get_visible_rect().size.y)
	
	curtain_left.position = Vector2(0, 0)
	curtain_right.position = Vector2(screen_width - curtain_width, 0)

signal i_shot_once
signal i_shot_twice
signal i_won
signal i_lost
