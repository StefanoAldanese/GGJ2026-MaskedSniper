extends Control

func _ready() -> void:
	# Make sure it's fully visible
	modulate.a = 1.0

	# Wait 5 seconds
	await get_tree().create_timer(5.0).timeout

	# Create a tween for the dissolve
	var tween := create_tween()
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		2.0
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Optional: wait for tween to finish, then remove the scene
	await tween.finished
	queue_free() # or hide() if you want to keep it
