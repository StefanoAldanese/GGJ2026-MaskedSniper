extends Node3D
class_name VenetianMask

# --- PERCORSI DELLE CARTELLE (ASSETS) ---
# Assicurati che queste cartelle esistano e contengano i file giusti
const PATH_PATTERNS = "res://assets/masks/patterns/"       # Texture in scala di grigi (PNG)
const PATH_ACCESSORIES = "res://assets/masks/accessories/" # Texture colorate con trasparenza (PNG)
const PATH_HEADGEARS = "res://assets/masks/headgears/"     # Texture colorate con trasparenza (PNG)
const PATH_SHAPES = "res://assets/masks/shapes/"           # Modelli 3D (.obj, .glb, .gltf)

# --- CONFIGURAZIONE COLORI ---
# Dizionario: "Nome che appare a schermo" -> Valore del Colore
const AVAILABLE_COLORS = {
	"Rosso Cremisi": Color(0.8, 0.0, 0.1),
	"Blu Notte": Color(0.1, 0.1, 0.5),
	"Oro": Color(1.0, 0.84, 0.0),
	"Verde Smeraldo": Color(0.0, 0.6, 0.3),
	"Nero": Color(0.1, 0.1, 0.1),
	"Viola Reale": Color(0.5, 0.0, 0.5),
	"Bianco": Color(0.95, 0.95, 0.95)
}

# --- RIFERIMENTI AI NODI ---
@onready var visual_mesh: MeshInstance3D = $Visual

# Carichiamo lo shader che gestisce i livelli (Layered Shader)
const LAYERED_SHADER = preload("res://shaders/mask_layered.gdshader")

# Questa variabile conterrà la frase finale (es. "Maschera a Becco Rossa...")
# Il nemico leggerà questa variabile per sapere chi è.
var description: String = ""

func _ready() -> void:
	# Appena la maschera viene creata, generiamo il suo aspetto
	# _generate_random_look()
	pass
	
# forbidden_description: La descrizione che NON deve uscire (quella del target)
func generate_safe_look(forbidden_description: String = "") -> void:
	var unique = false
	var attempts = 0
	
	# Tentiamo fino a 50 volte di generare qualcosa di diverso
	while !unique and attempts < 50:
		_generate_random_look()
		
		# Se non c'è divieto O se la descrizione è diversa da quella vietata
		if forbidden_description == "" or description != forbidden_description:
			unique = true
		else:
			attempts += 1
			
	if attempts >= 50:
		print("WARNING: Impossible to generate a Mask after 50 tries!")

func _generate_random_look() -> void:
	# Creiamo una nuova istanza del materiale shader per questa specifica maschera
	var material = ShaderMaterial.new()
	material.shader = LAYERED_SHADER
	
	# Variabili temporanee per costruire la frase descrittiva
	var desc_base = ""
	var extras = [] 
	
	# ---------------------------------------------------------
	# FASE 0: SCELTA DELLA FORMA 3D (SHAPE)
	# ---------------------------------------------------------
	# Cerchiamo un modello 3D nella cartella shapes
	var shape_data = _get_random_mesh_from_folder(PATH_SHAPES)
	var shape_name = ""
	
	if shape_data:
		# Se troviamo un file, lo applichiamo alla MeshInstance
		visual_mesh.mesh = shape_data.mesh
		shape_name = shape_data.name # Es: "A Becco" o "Tonda"
	
	# ---------------------------------------------------------
	# FASE 1: SCELTA DEL COLORE (TINTA BASE)
	# ---------------------------------------------------------
	# Prendiamo un nome a caso dalle chiavi del dizionario colori
	var random_col_name = AVAILABLE_COLORS.keys().pick_random()
	# Impostiamo il colore nello shader
	material.set_shader_parameter("mask_color", AVAILABLE_COLORS[random_col_name])
	
	# ---------------------------------------------------------
	# FASE 2: SCELTA DEL PATTERN (TEXTURE BASE)
	# ---------------------------------------------------------
	# Prendiamo una texture a caso dalla cartella patterns
	var pattern_data = _get_random_texture_from_folder(PATH_PATTERNS)
	
	# --- COSTRUZIONE DELLA PRIMA PARTE DELLA FRASE ---
	# Iniziamo a scrivere la descrizione.
	# Logica: "Maschera" + [Forma Opzionale] + [Colore]
	
	desc_base = "Maschera"
	if shape_name != "":
		desc_base += " " + shape_name # Es: "Maschera A Becco"
	
	desc_base += " " + random_col_name # Es: "Maschera A Becco Rosso Cremisi"
	
	if pattern_data:
		# Se abbiamo trovato un pattern, lo passiamo allo shader
		material.set_shader_parameter("pattern_texture", pattern_data.texture)
		# Aggiungiamo il nome del pattern alla frase
		desc_base += " " + pattern_data.name # Es: "... a Scacchi"
	
	# ---------------------------------------------------------
	# FASE 3: SCELTA DEL COPRICAPO (HEADGEAR)
	# ---------------------------------------------------------
	# Decidiamo se il nemico ha un cappello (50% di probabilità)
	if randf() > 0.5:
		var hat_data = _get_random_texture_from_folder(PATH_HEADGEARS)
		if hat_data:
			# Passiamo la texture e impostiamo l'opacità a 1 (visibile)
			material.set_shader_parameter("headgear_texture", hat_data.texture)
			material.set_shader_parameter("headgear_opacity", 1.0)
			# Aggiungiamo alla lista degli extra
			extras.append("indossa " + hat_data.name)
		else:
			# Se la cartella è vuota o errore, nascondiamo il livello
			material.set_shader_parameter("headgear_opacity", 0.0)
	else:
		# Se il random ha detto NO, nascondiamo il livello
		material.set_shader_parameter("headgear_opacity", 0.0)

	# ---------------------------------------------------------
	# FASE 4: SCELTA DELL'ACCESSORIO (ACCESSORY)
	# ---------------------------------------------------------
	# Decidiamo se il nemico ha un accessorio (50% di probabilità)
	if randf() > 0.5: 
		var acc_data = _get_random_texture_from_folder(PATH_ACCESSORIES)
		if acc_data:
			# Passiamo la texture e impostiamo l'opacità a 1 (visibile)
			material.set_shader_parameter("accessory_texture", acc_data.texture)
			material.set_shader_parameter("accessory_opacity", 1.0)
			# Aggiungiamo alla lista degli extra
			extras.append("con " + acc_data.name)
		else:
			material.set_shader_parameter("accessory_opacity", 0.0)
	else:
		material.set_shader_parameter("accessory_opacity", 0.0)

	# ---------------------------------------------------------
	# APPLICAZIONE FINALE
	# ---------------------------------------------------------
	# Assegniamo il materiale configurato alla mesh
	visual_mesh.material_override = material
	
	# Uniamo tutti i pezzi della descrizione in una frase naturale.
	# Se ci sono extra (cappello o accessori), li uniamo con " e ".
	# Esempio finale: "Maschera A Becco Rossa a Scacchi che indossa Tricorno e con Piuma"
	if extras.size() > 0:
		description = desc_base + " che " + " e ".join(extras)
	else:
		description = desc_base
		
	# Size Mask
	_force_mesh_size(2)


# --- FUNZIONI HELPER (DI UTILITÀ) ---

# Funzione 1: Carica immagini (PNG/JPG) da una cartella
# Restituisce un dizionario { "name": String, "texture": Texture2D }
func _get_random_texture_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		var files = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# Scansioniamo tutti i file nella cartella
		while file_name != "":
			# Ignoriamo i file nascosti (.) e prendiamo solo png o jpg
			if !file_name.begins_with(".") and (file_name.ends_with(".png") or file_name.ends_with(".jpg")):
				files.append(file_name)
			file_name = dir.get_next()
		
		# Se abbiamo trovato dei file validi...
		if files.size() > 0:
			var chosen_file = files.pick_random() # Ne scegliamo uno a caso
			var full_path = folder_path + chosen_file
			var texture = load(full_path)
			
			# Puliamo il nome del file per renderlo leggibile
			# Es: "cappello_buffo.png" -> diventa -> "Cappello Buffo"
			var clean_name = chosen_file.get_basename().replace("_", " ").capitalize()
			
			return { "name": clean_name, "texture": texture }
	
	return null # Ritorna null se la cartella è vuota o non esiste

# Funzione 2: Carica Modelli 3D (.obj/.glb) da una cartella
# Restituisce un dizionario { "name": String, "mesh": Mesh }
func _get_random_mesh_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		var files = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Qui cerchiamo estensioni di modelli 3D supportati da Godot
			if !file_name.begins_with(".") and (file_name.ends_with(".obj") or file_name.ends_with(".glb") or file_name.ends_with(".gltf")):
				files.append(file_name)
			file_name = dir.get_next()
		
		if files.size() > 0:
			var chosen_file = files.pick_random()
			var full_path = folder_path + chosen_file
			var mesh = load(full_path)
			
			# Puliamo il nome anche qui
			# Es: "volto_gatto.glb" -> "Volto Gatto"
			var clean_name = chosen_file.get_basename().replace("_", " ").capitalize()
			
			return { "name": clean_name, "mesh": mesh }
	
	return null

func _force_mesh_size(target_size: float) -> void:
	if visual_mesh.mesh == null:
		return
		
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
	
	# 4. Centramento (Fix altezza)
	var center_offset = aabb.get_center() * factor
	
	# 5. Applichiamo la posizione centrata...
	var base_position = -center_offset
	
	# 6. SPOSTAMENTO IN AVANTI (Fix "troppo dentro")
	# Aggiungiamo valore all'asse Z per spingerla fuori dalla faccia.
	# Prova con 0.15 o 0.20 (metri).
	var forward_push = 0.7 
	
	# NOTA: Se la maschera va ALL'INDIETRO, cambia il "+" in "-".
	base_position.z += forward_push 
	
	visual_mesh.position = base_position
