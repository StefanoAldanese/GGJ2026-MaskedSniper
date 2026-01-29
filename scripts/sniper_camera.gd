extends Camera3D

var target_y_offset: float = 0.0
const LOWERED_Y_POS = -5

@onready var fps_rig: Node3D = $fps_rig
@onready var anim_player: AnimationPlayer = $fps_rig/Sniper/AnimationPlayer
@onready var sniper_scope: MeshInstance3D = $fps_rig/Sniper/MeshInstance3D/Lent

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
		
func setup_scope_material(viewport_texture: ViewportTexture):
	var material = StandardMaterial3D.new()
	
	material.albedo_texture = viewport_texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED 
	
	
	# --- CORREZIONE COMANDI INVERTITI ---
	# Se muovi il mouse a DESTRA e la visuale va a SINISTRA, devi mettere -1 anche sulla X.
	# Qui mettiamo -1 sia su X che su Y per capovolgere tutto correttamente.
	material.uv1_scale = Vector3(-1, -1, 1) 
	
	# --- CENTRATURA ---
	# Poiché abbiamo messo -1 sia su X che su Y, dobbiamo compensare l'offset su entrambi.
	# Offset a 1 riporta l'immagine al centro.
	material.uv1_offset = Vector3(1, 1, 1)
	
	if sniper_scope:
		sniper_scope.material_override = material
