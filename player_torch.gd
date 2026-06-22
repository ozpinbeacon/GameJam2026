extends Node3D

# Torch on/off functionality
var torch_status: bool = true

func toggle_torch() -> void:
	if torch_status:
		self.hide()
		torch_status = false
	elif not torch_status:
		self.show()
		torch_status = true
		
