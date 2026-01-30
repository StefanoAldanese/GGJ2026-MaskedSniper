extends Node

# These are now the "Rewards" for winning
var day_scene = load("res://scenes/FlashScene.tscn")
var lore_scene = load("res://scenes/lore_card.tscn")
var game_scene_path = "res://scenes/world.tscn"


func _on_player_won():
	print("VITTORIA! Target eliminato.")
	_start_win_sequence()
	PlayerData.current_score += 100
	PlayerData.current_score += 1
	

func _on_player_lost():
	print("Sconfitta.")
	_start_death_sequence()

# --- WIN SEQUENCE (Lore + Flash) ---
func _start_win_sequence():

	if lore_scene:
		var lore = lore_scene.instantiate()
		get_tree().root.add_child(lore)
		await get_tree().create_timer(3.0).timeout
		lore.queue_free()
	
	# 3. Return to Menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(game_scene_path)

# --- LOSS SEQUENCE (Direct Exit) ---
func _start_death_sequence():
	# No lore, no flash. Just exit.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/UIStuff/main-menu.tscn")
