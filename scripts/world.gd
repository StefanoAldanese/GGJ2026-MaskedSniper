extends Node3D

@onready var sniper_nests: Array = $SniperNests.get_children()
@onready var player: CharacterBody3D = $Player/Character
@onready var enemies_container: Node = $Enemies # Assicurati che i nemici siano figli di questo nodo

func _ready():
	# 1. Setup Nidi Cecchino (tuo codice originale)
	set_nests_ready()
	
	# 2. Setup Nemici e Obiettivi (nuova logica)
	_initialize_enemies_logic()

# Funzione originale per i nidi
func set_nests_ready():
	var raw_children = $SniperNests.get_children()
	var nests: Array[Node3D] = []
	for child in raw_children:
		if child is Node3D:
			nests.append(child)
	player.set_sniper_nests(nests)

# Nuova logica Target-First
func _initialize_enemies_logic():
	# Aspettiamo un frame per sicurezza che tutti i nodi siano pronti
	await get_tree().process_frame
	
	var all_enemies = []
	for child in enemies_container.get_children():
		if child.has_method("spawn_mask"):
			all_enemies.append(child)
	
	if all_enemies.size() == 0:
		return

	# --- FASE A: SCELTA TARGET ---
	var target_enemy = all_enemies.pick_random()
	target_enemy.is_target = true
	
	# Genera il target liberamente (stringa vuota = nessuna restrizione)
	target_enemy.spawn_mask("") 
	var target_description = target_enemy.full_description
	
	# --- FASE B: GENERAZIONE ALTRI NEMICI ---
	for enemy in all_enemies:
		if enemy != target_enemy:
			# Diciamo agli altri: "Generati come vuoi, ma NON diventare come target_description"
			enemy.spawn_mask(target_description)
	
	# --- FASE C: COMUNICAZIONE AL PLAYER ---
	# Invia la descrizione del target al blocco note del giocatore
	if player.has_method("receive_target_list"):
		player.receive_target_list([target_description])
		
	# --- NUOVO: MESSAGGIO DI BENVENUTO ---
	if player.has_method("print_console_message"):
		# Attende 1 secondo per non sovrapporsi al caricamento
		await get_tree().create_timer(1.0).timeout
		player.print_console_message("SYSTEM: HELLO.\n MANKIND IS DEAD. \n BULLET ARE LIMITED. \n BALLROOM IS FULL.", 4.0)
