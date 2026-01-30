extends CharacterBody3D

@export var mask_scene: PackedScene 
@onready var head_socket: Marker3D = $Head
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

enum Personality { CALM, NORMAL, NERVOUS, AGGRESSIVE }

# State
var full_description: String = ""
var is_target: bool = false
var current_mask_node: Node3D = null
var bob_time := 0.0

# Personality stats
@export var base_speed := 1
@export var base_wander_radius := 10.0
@export var base_wait_time := 10

var speed: float
var wander_radius: float
var wait_time: float
var wait_timer := 0.0

@export var personality: Personality

func _ready() -> void:
	personality = Personality.values().pick_random()
	apply_personality()

func start_pathing():
	_set_new_random_target()

func go_into_panic():
	# Increase speed and reduce wait time
	speed = base_speed * 3.0       # Triple the speed
	wait_time = base_wait_time * 0.2 # Reduce wait time to 20%
	
	# Optional: Reset the current wait timer so they move immediately
	wait_timer = wait_time 
	
	# If you have a specific panic animation or color change, trigger it here
	# mod_sprite.modulate = Color.RED

func apply_personality():
	var speed_mul := 1.0
	var wander_mul := 1.0
	var wait_mul := 1.0

	match personality:
		Personality.CALM:
			speed_mul = 0.5; wander_mul = 0.8; wait_mul = 4
		Personality.NERVOUS:
			speed_mul = 1.8; wander_mul = 1.2; wait_mul = 1
		Personality.AGGRESSIVE:
			speed_mul = 1.2; wander_mul = 2.0; wait_mul = 0.2

	speed = base_speed * speed_mul
	wander_radius = base_wander_radius * wander_mul
	wait_time = base_wait_time * wait_mul 

func _physics_process(delta: float) -> void:
	# 1. MASK ROTATION (Horizontal Billboard Only)
	if current_mask_node:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var target_pos = camera.global_position
			# Force the 'look' to stay on the same horizontal plane
			target_pos.y = current_mask_node.global_position.y
			current_mask_node.look_at(target_pos, Vector3.UP)
			
	# 2. MOVEMENT LOGIC
	if navigation_agent_3d.is_navigation_finished():
		_handle_waiting(delta)
		return

	var destination = navigation_agent_3d.get_next_path_position()
	var direction = global_position.direction_to(destination)
	if global_position.distance_to(destination) > 0.1:
		velocity = direction * speed
		move_and_slide()
	else:
		_handle_waiting(delta)
	
	# 3. OPTIONAL: 2D Body Wobble (Visual Polish)
	if velocity.length() > 0.1:
		bob_time += delta * speed * 2.0
		# Simple tilt back and forth while walking
		rotation.z = deg_to_rad(sin(bob_time) * 5.0) 

func _handle_waiting(delta):
	velocity = Vector3.ZERO
	rotation.z = lerp(rotation.z, 0.0, 0.1) # Straighten up when stopping
	wait_timer += delta
	if wait_timer >= wait_time:
		_set_new_random_target()
		wait_timer = 0.0

func _set_new_random_target():
	var map = get_world_3d().navigation_map
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var raw_target = global_position + (random_dir * wander_radius)
	
	var safe_target = NavigationServer3D.map_get_closest_point(map, raw_target)
	navigation_agent_3d.target_position = safe_target

func spawn_mask(forbidden_desc: String = "") -> void:
	if mask_scene == null: return
		
	current_mask_node = mask_scene.instantiate()
	head_socket.add_child(current_mask_node)
	current_mask_node.position = Vector3.ZERO
	
	# This keeps the mask's rotation separate from the wobbling body
	current_mask_node.top_level = false 

	if current_mask_node.has_method("generate_safe_look"):
		current_mask_node.generate_safe_look(forbidden_desc)
		full_description = current_mask_node.description

func die() -> void:
	if is_target:
		print("VITTORIA! Hai eliminato il bersaglio: ", full_description)
	else:
		print("ERRORE! Hai ucciso un civile: ", full_description)
	queue_free()
