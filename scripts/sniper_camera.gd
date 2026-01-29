extends Camera3D

var target_y_offset: float = 0.0
const LOWERED_Y_POS = -5

@onready var fps_rig: Node3D = $fps_rig
@onready var anim_player: AnimationPlayer = $fps_rig/Sniper/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Movimento del fucile
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y, target_y_offset, delta*5)
	
func sway(sway_ammount):
	fps_rig.position.x -= sway_ammount.x*0.0005
	fps_rig.position.y += sway_ammount.y*0.0005

func set_lowered(is_lowered: bool):
	if is_lowered:
		target_y_offset = LOWERED_Y_POS
	else:
		target_y_offset = 0.0

func play_scope_anim(is_aiming: bool):
	if is_aiming:
		anim_player.play("scope_in")
	else:
		anim_player.play("scope_out")

func play_fire_anim(is_aiming: bool):
	# Interrompiamo l'animazione corrente per avere un feedback immediato dello sparo
	anim_player.stop()
	
	if is_aiming:
		anim_player.play("fire_scope")
	else:
		anim_player.play("fire_normal")
