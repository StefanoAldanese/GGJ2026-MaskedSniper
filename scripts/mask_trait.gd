extends Resource
class_name MaskTrait

@export var description_name: String = "" # Es: "Cremisi", "Damascato", "Piuma d'oro"

# Qui userai:
# - Per i PATTERN: Texture in scala di grigi (bianco e nero)
# - Per gli ACCESSORI: Texture a colori con sfondo trasparente
@export var texture_val: Texture2D 

# - Per i COLORI: Usare solo questo campo
@export var color_val: Color = Color.WHITE
