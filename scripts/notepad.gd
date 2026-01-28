extends Node3D

@onready var label: Label3D = $Paper/Text

const PAPER_WIDTH = 1.2
const PAPER_HEIGHT = 1.6
const MARGIN = 0.15            
const MAX_WIDTH_3D = PAPER_WIDTH - MARGIN
const MAX_HEIGHT_3D = PAPER_HEIGHT - MARGIN


# 0.0005 significa che ogni pixel è grande mezzo millimetro.
const BASE_PIXEL_SIZE = 0.001    

func update_target_info(targets: Array):
	var content = "ORDINE DI ELIMINAZIONE:\n\n"
	for t in targets:
		content += "- " + t + "\n"
	
	label.pixel_size = BASE_PIXEL_SIZE
	label.text = content
	
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	
	# Con 0.0005, avremo circa 520 pixel di larghezza disponibile
	label.width = MAX_WIDTH_3D / BASE_PIXEL_SIZE
	
	label.force_update_transform() 
	
	# Controllo altezza (uguale a prima)
	var text_aabb = label.get_aabb()
	var current_height_3d = text_aabb.size.y
	
	if current_height_3d > MAX_HEIGHT_3D:
		var scale_factor = MAX_HEIGHT_3D / current_height_3d
		label.pixel_size = BASE_PIXEL_SIZE * scale_factor
		label.width = MAX_WIDTH_3D / label.pixel_size
