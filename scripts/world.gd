extends Node3D

@export var enemy_scene: PackedScene 
@export var spawn_count: int = 15
@export var spawn_range := 30

@onready var sniper_nests: Array = $SniperNests.get_children()
@onready var player: CharacterBody3D = $Player/Character
@onready var enemies_container: Node = $Enemies

func _ready():
	# 1. Setup Nidi Cecchino (tuo codice originale)
	set_nests_ready()
	var created_enemies = await _spawn_enemies()
	# 2. Setup Nemici e Obiettivi (nuova logica)
	_initialize_enemies_logic(created_enemies)

func restart_scene():
	get_tree().reload_current_scene()

# Funzione originale per i nidi
func set_nests_ready():
	var raw_children = $SniperNests.get_children()
	var nests: Array[Node3D] = []
	for child in raw_children:
		if child is Node3D:
			nests.append(child)
	player.set_sniper_nests(nests)

func _spawn_enemies() -> Array:
	# Wait for NavMesh to be ready
	await get_tree().process_frame
	await NavigationServer3D.map_changed
	var map = get_world_3d().navigation_map
	var created_enemies = []
	
	for i in range(spawn_count):
		var enemy = enemy_scene.instantiate()
		enemies_container.add_child(enemy)
		
		# Position randomly
		var random_pos = Vector3(randf_range(-spawn_range, spawn_range), 0, randf_range(-spawn_range, spawn_range))
		var snapped_pos = NavigationServer3D.map_get_closest_point(map, random_pos)
		enemy.global_position = snapped_pos
		
		created_enemies.append(enemy)
	
	# CRITICAL: Wait one frame so the new enemies finish their own _ready() 
	# and initialize their @onready head sockets.
	await get_tree().process_frame
	
	return created_enemies

func _initialize_enemies_logic(created_enemies: Array):
	# Aspettiamo un frame per sicurezza che tutti i nodi siano pronti
	await get_tree().process_frame
	
	# --- FASE A: SCELTA TARGET ---
	var target_enemy = created_enemies.pick_random()
	target_enemy.is_target = true
	
	# Genera il target liberamente (stringa vuota = nessuna restrizione)
	target_enemy.spawn_mask("") 
	var target_description = target_enemy.full_description
	
	# --- FASE B: GENERAZIONE ALTRI NEMICI ---
	for enemy in created_enemies:
		if enemy != target_enemy:
			# Diciamo agli altri: "Generati come vuoi, ma NON diventare come target_description"
			enemy.spawn_mask(target_description)
			enemy.start_pathing()
	
	# --- FASE C: COMUNICAZIONE AL PLAYER ---
	# Invia la descrizione del target al blocco note del giocatore
	if player.has_method("receive_target_list"):
		player.receive_target_list([target_description])
