extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
# Ora puntiamo al nome corretto dopo la rinomina
@onready var modello_fucile: MeshInstance3D = $ModelloFucile 

var base_pos: Vector3

func _ready():
	# Salviamo la posizione locale impostata nell'editor
	base_pos = position

func set_aiming(is_aiming: bool):
	if is_aiming:
		animation_player.play("aim_in")
		# Rendiamo invisibile il mesh per vedere attraverso la camera senza ostacoli
		modello_fucile.visible = false 
	else:
		modello_fucile.visible = true
		animation_player.play("aim_out")

func play_shoot_anim():
	# Esegue l'animazione registrata nell'AnimationPlayer
	if animation_player.has_animation("shoot"):
		animation_player.play("shoot")
	
	# Rinculo supplementare via codice (Tween)
	apply_recoil()

func apply_recoil():
	var recoil_pos = base_pos + Vector3(0, 0, 0.1) # Arretra di 10cm
	var tween = create_tween()
	# Colpo indietro rapido
	tween.tween_property(self, "position", recoil_pos, 0.05)
	# Ritorno fluido
	tween.tween_property(self, "position", base_pos, 0.15)
