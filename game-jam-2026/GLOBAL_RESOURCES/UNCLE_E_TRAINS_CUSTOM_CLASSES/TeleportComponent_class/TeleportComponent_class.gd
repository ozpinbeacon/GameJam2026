extends Node
class_name TeleportComponent

@export var parent: Player


func teleport_to_position(target_transform: Transform3D)-> void:
	if parent == null:
		printerr(self, ": ERROR! Couldnt find parent node in exported variable.")
		return
	
	if parent.has_method("_on_disable_player"):
		print(self, ": disabling player")
		parent._on_disable_player()
		
	parent.call_deferred("set_physics_process", false)
	parent.set_deferred("global_transform", target_transform)
	
	await get_tree().create_timer(0.1).timeout
	parent.call_deferred("set_physics_process", true)
	
	if parent.has_method("_on_enable_player"):
		print(self, ": enabling player")
		parent._on_enable_player()
	
	SignalBus.broadcast_signal("teleport_complete")
	
	
