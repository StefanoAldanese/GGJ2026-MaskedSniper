extends Node3D

@onready var sniper_nests: Array = $SniperNests.get_children()
@onready var player: CharacterBody3D = $Player/Character

func set_nests_ready():
	var raw_children := $SniperNests.get_children() # Array[Node]

	var nests: Array[Node3D] = []

	for child in raw_children:
		if child is Node3D:
			nests.append(child)

	player.set_sniper_nests(nests)

func _ready():
	set_nests_ready()
