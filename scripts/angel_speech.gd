extends Node

@onready var line_1: Label = $MarginContainer/VBoxContainer/Label
@onready var line_2: Label = $MarginContainer/VBoxContainer/Label2
@onready var line_3: Label = $MarginContainer/VBoxContainer/Label3

@export var game_scene: PackedScene
@export var delay := 3.0

var current_step := 0
var timer: SceneTreeTimer

func _ready() -> void:
	line_1.visible = false
	line_2.visible = false
	line_3.visible = false
	
	run_sequence()

func _input(event: InputEvent) -> void:
	# Salta tutto il dialogo con Q
	if event.is_action_pressed("skip") or (event is InputEventKey and event.keycode == KEY_Q and event.pressed):
		start_game()
		return

	# Passa al prossimo messaggio con il Click Sinistro
	if event.is_action_pressed("shoot"):
		advance_sequence()

func run_sequence() -> void:
	# Step 1
	await wait_or_skip()
	line_1.visible = true
	current_step = 1
	
	# Step 2
	await wait_or_skip()
	line_2.visible = true
	current_step = 2
	
	# Step 3
	await wait_or_skip()
	line_3.visible = true
	current_step = 3
	
	# Step finale: Avvio gioco
	await wait_or_skip()
	start_game()

func wait_or_skip():
	# Questa funzione aspetta il delay oppure prosegue se l'utente clicca
	timer = get_tree().create_timer(delay)
	await timer.timeout

func advance_sequence():
	# Se l'utente clicca, forziamo il timer a finire immediatamente
	if timer and timer.time_left > 0:
		timer.time_left = 0 # Questo scatena il segnale timeout() istantaneamente

func start_game():
	# Impedisce doppie chiamate se si clicca freneticamente alla fine
	set_process_input(false) 
	get_tree().change_scene_to_file("res://scenes/world.tscn")
