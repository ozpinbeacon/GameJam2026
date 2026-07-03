extends DirectionalLight3D

var enabled = true

func _input(event) -> void:
	if event.is_action_pressed("debug_lighting"):
		if enabled:
			self.hide()
			enabled = false
		else:
			self.show()
			enabled = true
