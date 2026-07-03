extends Control

func _process(delta) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	
