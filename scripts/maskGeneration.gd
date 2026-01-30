extends Node3D
class_name VenetianMask

const PATH_PATTERNS = "res://assets/masks/patterns/"
const PATH_ACCESSORIES = "res://assets/masks/accessories/"
const PATH_HEADGEARS = "res://assets/masks/headgears/"
const PATH_SHAPES = "res://assets/masks/shapes/"

const AVAILABLE_COLORS = {
	"Red": Color(0.8, 0.0, 0.1),
	"Blue": Color(0.1, 0.1, 0.5),
	"Golden": Color(1.0, 0.84, 0.0),
	"Green": Color(0.0, 0.6, 0.3),
	"White": Color(0.95, 0.95, 0.95)
}

# --- RIFERIMENTI ---
@onready var visual_mesh: MeshInstance3D = $Visual
# Riferimenti ai nuovi nodi Sprite3D (Assicurati che i nomi coincidano nell'editor)
@onready var headgear_sprite: Sprite3D = $Visual/HeadgearSprite
@onready var accessory_sprite: Sprite3D = $Visual/AccessorySprite

const LAYERED_SHADER = preload("res://shaders/mask_layered.gdshader")

var description: String = ""
var typeMask: String = ""


const MAX_SPRITE_SIZE = 0.4


func _ready() -> void:
	pass

func generate_safe_look(forbidden_description: String = "") -> void:
	var unique = false
	var attempts = 0
	while !unique:
		_generate_random_look()
		if forbidden_description == "" or description != forbidden_description:
			unique = true
		else:
			attempts += 1
	if attempts >= 50:
		print("WARNING: Impossible to generate a Mask after 50 tries!")

func _generate_random_look() -> void:
	var material = ShaderMaterial.new()
	material.shader = LAYERED_SHADER
	
	# 1. Reset degli Sprite
	headgear_sprite.texture = null
	accessory_sprite.texture = null
	
	# 2. Forma e Colore (Base)
	var shape_data = _get_random_mesh_from_folder(PATH_SHAPES)
	if shape_data:
		visual_mesh.mesh = shape_data.mesh
		typeMask = shape_data.name
		description += shape_data.name
	
	var random_col_name = AVAILABLE_COLORS.keys().pick_random()
	material.set_shader_parameter("mask_color", AVAILABLE_COLORS[random_col_name])
	description += " " + random_col_name + " "
	
	var pattern_data = _get_random_texture_from_folder(PATH_PATTERNS)
	if pattern_data:
		material.set_shader_parameter("pattern_texture", pattern_data.texture)

	# 3. Gestione Cappello (Scala corretta)
	if randf() > 0.5:
		var hat_data = _get_random_texture_from_folder(PATH_HEADGEARS)
		if hat_data:
			headgear_sprite.texture = hat_data.texture
			# Rimpiccioliamo lo sprite: 0.001 è 10 volte più piccolo del default
			headgear_sprite.pixel_size = 0.0015 
			# Lo spostiamo un po' in avanti per non farlo compenetrare con la maschera
			headgear_sprite.position.z = 1.6
			headgear_sprite.position.y = 2.0
			description += ", wearing " + hat_data.name

	# 4. Gestione Accessorio (Scala corretta)
	if randf() > 0.5: 
		var acc_data = _get_random_texture_from_folder(PATH_ACCESSORIES)
		if acc_data:
			accessory_sprite.texture = acc_data.texture
			accessory_sprite.pixel_size = 0.0015 # Ancora più piccolo
			accessory_sprite.position.z = 1.5 # Davanti al cappello (sandwich)
			headgear_sprite.position.y = -2
			description += " and " + acc_data.name + " accessory "
			
	visual_mesh.material_override = material
	_force_mesh_size(0.8)

# --- HELPER FUNCTIONS (Invariate tranne force_mesh_size) ---

func _get_random_texture_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		var files = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !file_name.begins_with(".") and (file_name.ends_with(".png") or file_name.ends_with(".jpg")):
				files.append(file_name)
			file_name = dir.get_next()
		if files.size() > 0:
			var chosen_file = files.pick_random()
			var full_path = folder_path + chosen_file
			var texture = load(full_path)
			var clean_name = chosen_file.get_basename().replace("_", " ").capitalize()
			return { "name": clean_name, "texture": texture }
	return null

func _get_random_mesh_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		var files = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !file_name.begins_with("."):
				var clean_file = file_name.replace(".import", "")
				if clean_file.ends_with(".obj") or clean_file.ends_with(".glb") or clean_file.ends_with(".res"):
					if not files.has(clean_file):
						files.append(clean_file)
			file_name = dir.get_next()
		if files.size() > 0:
			var chosen_file = files.pick_random()
			var full_path = folder_path + chosen_file
			var mesh = load(full_path)
			var clean_name = chosen_file.get_basename().replace("_", " ").capitalize()
			return { "name": clean_name, "mesh": mesh }
	return null

func _force_mesh_size(target_size: float) -> void:
	if visual_mesh.mesh == null: return
		
	# 1. Reset
	visual_mesh.scale = Vector3.ONE
	visual_mesh.position = Vector3.ZERO
	
	# 2. Calcolo dimensione
	var aabb = visual_mesh.mesh.get_aabb()
	var current_max = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
	if current_max == 0: return
		
	# 3. Scala
	var factor = target_size / current_max
	visual_mesh.scale = Vector3(factor, factor, factor)
	
	# 4. Centramento
	var center_offset = aabb.get_center() * factor
	var base_position = -center_offset
	
	# 5. Spostamenti
	var forward_push = -0.2 
	base_position.z += forward_push 
	
	var vertical_raise = 0.15 
	base_position.y += vertical_raise
	
	visual_mesh.position = base_position
