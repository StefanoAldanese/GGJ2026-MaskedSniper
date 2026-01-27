extends Node3D

@onready var enemy = $Enemy
@onready var desc_label = $UI/DescriptionLabel
@onready var stats_label = $UI/StatsLabel
@onready var generate_button = $UI/GenerateButton

func _ready():
	randomize()
	
	# Collega i segnali dei bottoni
	if generate_button:
		generate_button.pressed.connect(_on_generate_pressed)
	
	# Genera la prima maschera
	generate_new_mask()
	
	# Mostra le statistiche delle risorse
	update_stats_display()

func _input(event):
	if event.is_action_pressed("ui_accept"): # Tasto SPAZIO
		generate_new_mask()
	
	if event.is_action_pressed("ui_cancel"): # Tasto ESC
		get_tree().quit()

func _on_generate_pressed():
	generate_new_mask()

func generate_new_mask():
	print("===================")
	print("GENERAZIONE MASCHERA IN LABORATORIO")
	print("===================")
	
	var descrizione = enemy.generate_random_enemy()
	
	# Aggiorna la UI
	if desc_label:
		desc_label.text = descrizione
	
	# Aggiorna le statistiche
	update_stats_display()
	
	# Log
	print("Descrizione generata: ", descrizione)

func update_stats_display():
	if stats_label and enemy:
		var stats = enemy.get_components_summary()
		stats_label.text = "Risorse disponibili:\n"
		stats_label.text += "• Forme: %d\n" % stats.shapes
		stats_label.text += "• Colori: %d\n" % stats.colors
		stats_label.text += "• Pattern: %d\n" % stats.patterns
		stats_label.text += "• Accessori: %d" % stats.accessories
