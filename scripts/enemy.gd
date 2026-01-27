extends Area3D

# Riferimento alla SCENA della maschera (trascinare il file mask.tscn qui nell'inspector)
@export var mask_scene: PackedScene 

# Riferimento al punto di aggancio
@onready var head_socket: Marker3D = $Head

# Variabile per memorizzare chi sono
var full_description: String = ""
var is_target: bool = false # Per logica di gioco futura (punteggio/streak)

func _ready() -> void:
# Non facciamo nulla qui. Aspettiamo il World.
	pass

func spawn_mask(forbidden_desc: String = "") -> void:
	if mask_scene == null:
		push_error("Mask Scene non assegnata nel nemico!")
		return
		
	# 1. Istanziamo la maschera
	var current_mask = mask_scene.instantiate()
	
	# 2. La attacchiamo al "collo" (HeadSocket)
	head_socket.add_child(current_mask)
	
	# 3. Importante: Resettiamo la trasformazione locale così si allinea al socket
	current_mask.position = Vector3.ZERO
	current_mask.rotation = Vector3.ZERO
	
	# 4. Leggiamo la descrizione generata dalla maschera
	# Nota: _ready() della maschera viene chiamato appena facciamo add_child
	# quindi la descrizione è già pronta.
	if current_mask.has_method("generate_safe_look"):
			current_mask.generate_safe_look(forbidden_desc)
			full_description = current_mask.description
			
			# Debug print
			if is_target:
				print("[TARGET] ", full_description)
			else:
				print("[NEMICO] ", full_description)

func die() -> void:
	if is_target:
		print("VITTORIA! Hai eliminato il bersaglio: ", full_description)
	else:
		print("ERRORE! Hai ucciso un civile: ", full_description)
	queue_free()
