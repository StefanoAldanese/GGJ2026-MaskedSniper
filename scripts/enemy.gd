extends CharacterBody3D

# --- VARIABILI PER CARICAMENTO AUTOMATICO ---
@export_category("Auto Loading")
@export var use_auto_loading: bool = true
@export var shapes_folder: String = "res://assets/masks/shapes"
@export var colors_folder: String = "res://assets/masks/colors"
@export var patterns_folder: String = "res://assets/masks/patterns"
@export var accessories_folder: String = "res://assets/masks/accessories"

# --- VARIABILI PER OVERRIDE MANUALE (opzionale) ---
@export_category("Manual Override")
@export var manual_shapes: Array[MaskShapeData]
@export var manual_colors: Array[MaskVisualData]
@export var manual_patterns: Array[MaskVisualData]
@export var manual_accessories: Array[MaskAccessoryData]

# --- VARIABILI INTERNE ---
var shapes: Array[MaskShapeData] = []
var colors: Array[MaskVisualData] = []
var patterns: Array[MaskVisualData] = []
var accessories: Array[MaskAccessoryData] = []

# Variabili per prevenire ripetizioni consecutive
var last_shape: MaskShapeData = null
var last_color: MaskVisualData = null
var last_pattern: MaskVisualData = null
var last_accessory: MaskAccessoryData = null

# Riferimenti ai nodi
@onready var mask_mesh_instance = $MaskPivot/MaskMesh
@onready var accessory_sprite = $MaskPivot/AccessorySprite

func _ready():
	print("=== ENEMY INITIALIZATION ===")
	load_all_resources()
	
	# Genera una maschera iniziale se abbiamo risorse sufficienti
	if can_generate_mask():
		generate_random_enemy()
	else:
		print("AVVISO: Non ci sono risorse sufficienti per generare una maschera")
		print("Shapes: ", shapes.size(), " | Colors: ", colors.size())

func _input(event):
	# DEBUG: Premere G per rigenerare
	if event.is_action_pressed("ui_select"): # Default: Spazio
		generate_random_enemy()

# ===== SISTEMA DI CARICAMENTO RISORSE =====
func load_all_resources():
	print("Caricamento risorse in corso...")
	
	# Usa override manuale se specificato, altrimenti carica automaticamente
	if not manual_shapes.is_empty():
		print("Usando shapes manuali: ", manual_shapes.size())
		shapes = manual_shapes.duplicate()
	elif use_auto_loading:
		shapes = load_resources_from_folder(shapes_folder, MaskShapeData)
	
	if not manual_colors.is_empty():
		print("Usando colors manuali: ", manual_colors.size())
		colors = manual_colors.duplicate()
	elif use_auto_loading:
		colors = load_resources_from_folder(colors_folder, MaskVisualData)
	
	if not manual_patterns.is_empty():
		print("Usando patterns manuali: ", manual_patterns.size())
		patterns = manual_patterns.duplicate()
	elif use_auto_loading:
		patterns = load_resources_from_folder(patterns_folder, MaskVisualData)
	
	if not manual_accessories.is_empty():
		print("Usando accessories manuali: ", manual_accessories.size())
		accessories = manual_accessories.duplicate()
	elif use_auto_loading:
		accessories = load_resources_from_folder(accessories_folder, MaskAccessoryData)
	
	print("Risorse caricate:")
	print("  • Shapes: ", shapes.size())
	print("  • Colors: ", colors.size())
	print("  • Patterns: ", patterns.size())
	print("  • Accessories: ", accessories.size())

func load_resources_from_folder(folder_path: String, resource_type: GDScript) -> Array:
	var resources = []
	
	# Verifica se la cartella esiste
	if not DirAccess.dir_exists_absolute(folder_path):
		print("AVVISO: Cartella non trovata: ", folder_path)
		return resources
	
	var dir = DirAccess.open(folder_path)
	if dir == null:
		print("ERRORE: Impossibile aprire la cartella: ", folder_path)
		return resources
	
	var error = dir.list_dir_begin()
	if error != OK:
		print("ERRORE: Impossibile leggere la cartella: ", folder_path)
		return resources
	
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path = folder_path.path_join(file_name)
			var resource = load(full_path)
			
			if resource and resource is resource_type:
				resources.append(resource)
				#print("  ✓ Caricato: ", file_name)
			else:
				print("  ✗ Ignorato (tipo errato): ", file_name)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	if resources.is_empty():
		print("  Nessuna risorsa trovata in: ", folder_path)
	
	return resources

# ===== SISTEMA DI GENERAZIONE MASCHERA =====
func generate_random_enemy() -> String:
	print("\n--- GENERAZIONE NUOVA MASCHERA ---")
	
	# Controllo di sicurezza
	if not can_generate_mask():
		return "Errore: Risorse insufficienti per generare una maschera!"
	
	# --- 1. ESTRAZIONE COMPONENTI (con prevenzione ripetizioni) ---
	var my_shape = get_unique_component(shapes, last_shape)
	var my_color = get_unique_component(colors, last_color)
	
	# Pattern e accessori sono opzionali
	var my_pattern = null
	if not patterns.is_empty():
		my_pattern = get_unique_component(patterns, last_pattern)
	
	var my_accessory = null
	if not accessories.is_empty():
		my_accessory = get_unique_component(accessories, last_accessory)
	
	# Salva per la prossima generazione
	last_shape = my_shape
	last_color = my_color
	last_pattern = my_pattern
	last_accessory = my_accessory
	
	# --- 2. APPLICAZIONE ALLA MASCHERA ---
	apply_mask_components(my_shape, my_color, my_pattern, my_accessory)
	
	# --- 3. ROTAZIONE PER VISUALIZZAZIONE MIGLIORE ---
	rotate_y(randf_range(-0.3, 0.3)) # Leggera rotazione casuale
	
	# --- 4. DESCRIZIONE ---
	var descrizione = costruisci_descrizione(my_shape, my_color, my_pattern, my_accessory)
	print("DESCRIZIONE: ", descrizione)
	
	return descrizione

func can_generate_mask() -> bool:
	# Almeno shape e color sono obbligatori
	return shapes.size() > 0 and colors.size() > 0

func get_unique_component(component_list: Array, last_component) -> Variant:
	if component_list.is_empty():
		return null
	
	# Se c'è solo un componente, usalo
	if component_list.size() == 1:
		return component_list[0]
	
	# Se abbiamo un componente precedente, evitiamo di ripeterlo
	var component = component_list.pick_random()
	var attempts = 0
	while component == last_component and attempts < 10:
		component = component_list.pick_random()
		attempts += 1
	
	return component

func apply_mask_components(shape: MaskShapeData, color: MaskVisualData, pattern: MaskVisualData, accessory: MaskAccessoryData):
	# --- SHAPE 3D ---
	if shape and shape.mesh:
		mask_mesh_instance.mesh = shape.mesh
	else:
		print("AVVISO: Nessuna shape valida selezionata")
	
	# --- MATERIALE CON COLORE E PATTERN ---
	var new_mat = StandardMaterial3D.new()
	new_mat.albedo_color = color.tint_color if color else Color.WHITE
	
	if pattern and pattern.albedo_texture:
		new_mat.albedo_texture = pattern.albedo_texture
		new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		new_mat.albedo_texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	
	mask_mesh_instance.material_override = new_mat
	
	# --- ACCESSORIO 2D ---
	if accessory and accessory.sprite:
		accessory_sprite.texture = accessory.sprite
		accessory_sprite.position = Vector3(0, 0, 0.1) + (accessory.offset if accessory.offset else Vector3.ZERO)
		accessory_sprite.visible = true
	else:
		accessory_sprite.visible = false
	
	# DEBUG: Log dei componenti applicati
	print("Componenti applicati:")
	print("  • Shape: ", shape.id if shape else "Nessuna")
	print("  • Color: ", color.id if color else "Nessuno")
	print("  • Pattern: ", pattern.id if pattern else "Nessuno")
	print("  • Accessory: ", accessory.id if accessory else "Nessuno")

func costruisci_descrizione(shape: MaskShapeData, color: MaskVisualData, pattern: MaskVisualData, accessory: MaskAccessoryData) -> String:
	var testo = "Indossa "
	
	if shape:
		testo += shape.description_segment
	else:
		testo += "una maschera"
	
	if color:
		testo += " " + color.description_segment
	
	if pattern:
		testo += ", " + pattern.description_segment
	
	if accessory:
		testo += " e " + accessory.description_segment
	
	return testo + "."

# ===== FUNZIONI UTILITY =====
func get_components_summary() -> Dictionary:
	return {
		"shapes": shapes.size(),
		"colors": colors.size(),
		"patterns": patterns.size(),
		"accessories": accessories.size()
	}

func force_regenerate():
	last_shape = null
	last_color = null
	last_pattern = null
	last_accessory = null
	generate_random_enemy()
