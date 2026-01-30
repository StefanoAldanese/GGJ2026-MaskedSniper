extends Node3D

@export var enemy_scene: PackedScene 
@export var spawn_count: int = 15
@export var spawn_range := 30

@onready var sniper_nests: Array = $SniperNests.get_children()
@onready var player: CharacterBody3D = $Player/Character
@onready var enemies_container: Node = $Enemies

@onready var nickname_label: Label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/NicknameLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/ScoreLabel
@onready var night_label: Label = $MarginContainer/HBoxContainer/TextureRect/NightLabel

@onready var bullet_counter_blue: TextureRect = $MarginContainer/HBoxContainer/BulletCounterAround/BulletCounterBlue
@onready var bullet_counter_red: TextureRect = $MarginContainer/HBoxContainer/BulletCounterAround/BulletCounterRed

@onready var message_screen_won: PanelContainer = $MessageScreenWon
@onready var message_screen_lost: PanelContainer = $MessageScreenLost

func _ready():
	# 1. Setup riferimenti UI al Player ### AGGIUNTA ###
	player.bullet_ui_blue = bullet_counter_blue
	player.bullet_ui_red = bullet_counter_red
	
	# 2. Setup Nidi Cecchino (tuo codice originale)
	initialize_player_data()
	initialize_player_signals()
	set_nests_ready()
	var created_enemies = await _spawn_enemies()
	# 3. Setup Nemici e Obiettivi (nuova logica)
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
	
	NavigationServer3D.map_changed.connect(func(_id): pass, CONNECT_ONE_SHOT) # Dummy connect to wake it up
	await get_tree().physics_frame
	
	# await NavigationServer3D.map_changed
	var map = get_world_3d().navigation_map
	
	var test_point = NavigationServer3D.map_get_closest_point(map, Vector3(10, 0, 10))
	if test_point == Vector3.ZERO:
		# If it failed, wait one more frame. This usually solves reload race conditions.
		await get_tree().create_timer(0.1).timeout
	
	var created_enemies = []
	
	for i in range(spawn_count):
		var enemy = enemy_scene.instantiate()
		enemies_container.add_child(enemy)
		
		# Position randomly
		var random_pos = Vector3(randf_range(-spawn_range, spawn_range), 0, randf_range(-spawn_range, spawn_range))
		var snapped_pos = NavigationServer3D.map_get_closest_point(map, random_pos)
		# If it still returns ZERO, at least use the random_pos so they don't bunch up
		if snapped_pos == Vector3.ZERO:
			enemy.global_position = random_pos
		else:
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
		
func initialize_player_data():
	nickname_label.text = PlayerData.current_nickname
	score_label.text = str(PlayerData.current_score)
	night_label.text = str(PlayerData.current_day)

func initialize_player_signals():
	if player.has_signal("i_won"):
		player.i_won.connect(_on_i_won)
	if player.has_signal("i_lost"):
		player.i_lost.connect(_on_i_lost)
	if player.has_signal("i_shot_once"):
		player.i_shot_once.connect(_on_i_shot_once)
	if player.has_signal("i_shot_twice"):
		player.i_shot_twice.connect(_on_i_shot_twice)
		
func _on_i_won():
	print("Message I won")
	message_screen_won.visible = true
	
func _on_i_lost():
	print("Message I lost")
	message_screen_lost.visible = true
	
func _on_i_shot_once():
	print("Message I shot once")
	
func _on_i_shot_twice():
	print("Message I shot twice")
