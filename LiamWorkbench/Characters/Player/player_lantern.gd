extends Node3D

@onready var light = $SpotLight3D

# Torch on/off functionality
var lantern_status: bool = true

func toggle_lantern() -> void:
	if lantern_status:
		light.hide()
		lantern_status = false
	elif not lantern_status:
		light.show()
		lantern_status = true
		
