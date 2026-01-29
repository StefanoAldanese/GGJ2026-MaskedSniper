extends Camera3D

@onready var fps_rig: Node3D = $fps_rig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Movimento del fucile
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta*5)
	
func sway(sway_ammount):
	fps_rig.position.x -= sway_ammount.x*0.0005
	fps_rig.position.y += sway_ammount.y*0.0005
