extends Node
@onready var line_1: Label = $MarginContainer/VBoxContainer/Label
@onready var line_2: Label = $MarginContainer/VBoxContainer/Label2
@onready var line_3: Label = $MarginContainer/VBoxContainer/Label3

@export var game_scene: PackedScene
@export var delay := 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_1.visible = false
	line_2.visible = false
	line_3.visible = false

	await get_tree().create_timer(delay).timeout
	line_1.visible = true

	await get_tree().create_timer(delay).timeout
	line_2.visible = true

	await get_tree().create_timer(delay).timeout
	line_3.visible = true

	await get_tree().create_timer(delay).timeout
	start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start_game():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
