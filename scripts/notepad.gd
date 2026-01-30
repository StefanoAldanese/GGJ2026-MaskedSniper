extends Node3D

@onready var label: Label3D = $Paper/Text
@onready var photo_sprite: Sprite3D = $Polaroid/Sprite3D

const PAPER_WIDTH = 1.2
const PAPER_HEIGHT = 1.6
const BASE_PIXEL_SIZE = 0.001       
const MASK_PHOTO_PATH = "res://assets/Notepad/maskPhoto/"

# --- MODIFICA QUESTO VALORE PER STRINGERE IL TESTO ---
# Se metti 900 è largo, se metti 300 è molto stretto.
# Prova con 400 o 500 per vedere l'effetto "a capo" immediato.
const TEXT_COLUMN_WIDTH_PIXEL = 400.0 

# Calcoliamo l'altezza massima in 3D (per il ridimensionamento se il testo è troppo lungo)
# Usiamo un margine di sicurezza (0.2 sopra e 0.2 sotto)
const MAX_HEIGHT_3D = PAPER_HEIGHT - 0.4 

func update_target_info(targets: Array):
	# --- 1. COSTRUZIONE TESTO ---
	var content = "ORDER OF ELIMINATION:\n\n"
	for t in targets:
		content += "- " + t + "\n"
	
	label.text = content
	
	# --- 2. IMPOSTAZIONE LARGHEZZA FORZATA ---
	label.pixel_size = BASE_PIXEL_SIZE
	
	# Questo è il comando magico: Autowrap SMART cerca di non spezzare le parole a metà
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART 
	
	# Qui imponiamo la larghezza in pixel. 
	# Se il testo supera 450px (o quello che hai messo), va a capo.
	label.width = TEXT_COLUMN_WIDTH_PIXEL 
	
	label.force_update_transform() 
	
	# --- 3. CONTROLLO E RIDIMENSIONAMENTO (ZOOM OUT) ---
	# Se, andando a capo tante volte, il testo diventa troppo alto e esce dal foglio...
	var text_aabb = label.get_aabb()
	var current_height_3d = text_aabb.size.y
	
	if current_height_3d > MAX_HEIGHT_3D:
		# ...rimpiccioliamo tutto (riducendo il pixel_size)
		var scale_factor = MAX_HEIGHT_3D / current_height_3d
		label.pixel_size = BASE_PIXEL_SIZE * scale_factor
		
		# IMPORTANTE: Se rimpiccioliamo i pixel, dobbiamo AUMENTARE la width in proporzione
		# per mantenere visivamente la stessa colonna stretta sul foglio.
		label.width = TEXT_COLUMN_WIDTH_PIXEL / scale_factor
		
	# --- 4. CARICAMENTO FOTO ---
	_load_target_photo()

func _load_target_photo():
	var mask_type = PlayerData.target_mask_type
	if mask_type == "":
		photo_sprite.texture = null
		return

	var full_path = MASK_PHOTO_PATH + mask_type + ".png"
	if ResourceLoader.exists(full_path):
		photo_sprite.texture = load(full_path)
	else:
		print("ERRORE: Immagine non trovata: ", full_path)
