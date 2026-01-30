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
		
		
#I'm Burining out
func setup_scope_material(viewport_texture: ViewportTexture):
	# Creiamo uno ShaderMaterial invece dello StandardMaterial3D
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	
	# Scriviamo il codice dello shader direttamente qui dentro.
	# Questo shader fa due cose:
	# 1. Mostra la texture.
	# 2. Rende invisibile tutto ciò che è fuori dal cerchio (raggio 0.5).
	shader.code = """
	shader_type spatial;
	render_mode unshaded, cull_disabled; // Unshaded per vederlo al buio

	uniform sampler2D lens_tx : source_color, filter_linear_mipmap;

	void fragment() {
		// Mappatura UV standard
		vec2 uv = UV;
		
		// 1. Mostra l'immagine della camera
		vec4 color = texture(lens_tx, uv);
		ALBEDO = color.rgb;

		// 2. TAGLIO CIRCOLARE (Cookie Cutter)
		// Calcola la distanza dal centro (0.5, 0.5)
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(uv, center);

		// Se siamo distanti più di 0.5 dal centro (fuori dal cerchio), Alpha a 0.
		// Usiamo smoothstep per un bordo leggermente morbido (anti-aliasing)
		float alpha = 1.0 - smoothstep(0.49, 0.50, dist);
		
		ALPHA = alpha;
	}
	"""
	
	# Assegniamo lo shader creato al materiale
	material.shader = shader
	
	# Passiamo la texture del Viewport allo shader
	material.set_shader_parameter("lens_tx", viewport_texture)
	
	# Applichiamo il materiale alla mesh
	if sniper_scope:
		sniper_scope.material_override = material
