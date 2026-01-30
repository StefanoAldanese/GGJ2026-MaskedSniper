extends Node3D

@onready var label: Label3D = $Paper/Text

# 1. Riferimento allo Sprite3D che mostrerà la foto
@onready var photo_sprite: Sprite3D = $TargetPhoto/Sprite3D 

const PAPER_WIDTH = 1.2
const PAPER_HEIGHT = 1.6
const MARGIN = 0.15            
const MAX_WIDTH_3D = PAPER_WIDTH - MARGIN
const MAX_HEIGHT_3D = PAPER_HEIGHT - MARGIN
const BASE_PIXEL_SIZE = 0.001    

# 2. Definiamo il percorso base dove hai le immagini
const MASK_PHOTO_PATH = "res://assets/Notepad/maskPhoto/"

func update_target_info(targets: Array):
	# --- LOGICA TESTO (Tuo codice esistente) ---
	var content = "ORDINE DI ELIMINAZIONE:\n\n"
	for t in targets:
		content += "- " + t + "\n"
	
	label.pixel_size = BASE_PIXEL_SIZE
	label.text = content
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.width = MAX_WIDTH_3D / BASE_PIXEL_SIZE
	label.force_update_transform() 
	
	var text_aabb = label.get_aabb()
	var current_height_3d = text_aabb.size.y
	
	if current_height_3d > MAX_HEIGHT_3D:
		var scale_factor = MAX_HEIGHT_3D / current_height_3d
		label.pixel_size = BASE_PIXEL_SIZE * scale_factor
		label.width = MAX_WIDTH_3D / label.pixel_size
		
	# --- 3. LOGICA FOTO (NUOVA) ---
	_load_target_photo()

func _load_target_photo():
	# Recuperiamo il tipo salvato nel singleton (es. "Larva", "Bruta")
	var mask_type = PlayerData.target_mask_type
	
	if mask_type == "":
		print("Nessun tipo di maschera specificato nel PlayerData.")
		photo_sprite.texture = null # Pulisce se non c'è target
		return

	# Costruiamo il percorso completo: "res://.../Larva.png"
	# Nota: Assicurati che mask_type abbia la stessa capitalizzazione del file (es. Larva vs larva)
	var full_path = MASK_PHOTO_PATH + mask_type + ".png"
	
	# Controlliamo se il file esiste prima di caricarlo per evitare crash
	if ResourceLoader.exists(full_path):
		var texture = load(full_path)
		photo_sprite.texture = texture
		print("Foto caricata con successo: ", full_path)
	else:
		print("ERRORE: Immagine non trovata al percorso: ", full_path)
		# Opzionale: Carica un'immagine di default/errore
		# photo_sprite.texture = load("res://assets/Notepad/maskPhoto/unknown.png")
