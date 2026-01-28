extends Area3D

# Riferimento alla SCENA della maschera (trascinare il file mask.tscn qui nell'inspector)
@export var mask_scene: PackedScene 

# Riferimento al punto di aggancio
@onready var head_socket: Marker3D = $Head

@onready var separation_area: Area3D = $DetectionArea

enum Personality {
	CALM,
	NORMAL,
	NERVOUS,
	AGGRESSIVE
}


# Variabile per memorizzare chi sono
var full_description: String = ""
var is_target: bool = false # Per logica di gioco futura (punteggio/streak)

# Personality tuning
var speed := 2.0
var wander_radius := 5.0
var wait_time := 2.0
var separation_strength := 3.0

var target_position: Vector3
var wait_timer := 0.0

func _ready() -> void:
	apply_personality()
	pick_new_target()

func apply_personality():
	match Personality:
		Personality.CALM:
			speed = 1.5
			wander_radius = 3.0
			wait_time = 3.0
			separation_strength = 2.0
		Personality.NORMAL:
			speed = 2.0
			wander_radius = 5.0
			wait_time = 2.0
			separation_strength = 3.0
		Personality.NERVOUS:
			speed = 3.5
			wander_radius = 7.0
			wait_time = 1.0
			separation_strength = 4.0
		Personality.AGGRESSIVE:
			speed = 3.0
			wander_radius = 6.0
			wait_time = 0.5
			separation_strength = 5.0
			
func pick_new_target():
	var random_dir = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	).normalized()

	target_position = global_position + random_dir * randf_range(1.0, wander_radius)

func _physics_process(delta):
	var move_dir = Vector3.ZERO

	# Move toward target
	var to_target = target_position - global_position
	if to_target.length() > 0.5:
		move_dir += to_target.normalized()
	else:
		wait_timer += delta
		if wait_timer >= wait_time:
			wait_timer = 0.0
			pick_new_target()

	# Separation force
	for body in separation_area.get_overlapping_bodies():
		if body == self:
			continue

		var away = global_position - body.global_position
		var dist = away.length()
		if dist > 0.01:
			move_dir += away.normalized() * (separation_strength / dist)

	# Apply movement
	if move_dir != Vector3.ZERO:
		velocity = move_dir.normalized() * speed
	else:
		velocity = Vector3.ZERO

	move_and_slide()

			
func spawn_mask(forbidden_desc: String = "") -> void:
	if mask_scene == null:
		push_error("Mask Scene non assegnata nel nemico!")
		return
		
	# 1. Istanziamo la maschera
	var current_mask = mask_scene.instantiate()
	
	# 2. La attacchiamo al "collo" (HeadSocket)
	head_socket.add_child(current_mask)
	
	# 3. Importante: Resettiamo la trasformazione locale così si allinea al socket
	current_mask.position = Vector3.ZERO
	current_mask.rotation = Vector3.ZERO
	
	# 4. Leggiamo la descrizione generata dalla maschera
	# Nota: _ready() della maschera viene chiamato appena facciamo add_child
	# quindi la descrizione è già pronta.
	if current_mask.has_method("generate_safe_look"):
			current_mask.generate_safe_look(forbidden_desc)
			full_description = current_mask.description
			
			# Debug print
			if is_target:
				print("[TARGET] ", full_description)
			else:
				print("[NEMICO] ", full_description)

func die() -> void:
	if is_target:
		print("VITTORIA! Hai eliminato il bersaglio: ", full_description)
	else:
		print("ERRORE! Hai ucciso un civile: ", full_description)
	queue_free()
