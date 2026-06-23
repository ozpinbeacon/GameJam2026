extends Node3D

var bleed_intensity_property_path: String = "mesh/material/next_pass/shader_parameter/intensity"

@export var mesh_instance_3d: MeshInstance3D
@export var object_id: String = ""##Unique ID to use when recieving signals to start bleeding on a specific object
@export var target_value: float = 1.0


func _ready() -> void:
	connect_signals()

func connect_signals()-> void:
	SignalBus.connect_signal(self, "start_bleeding")


func _on_start_bleeding(object_id: String, duration: float = 4.0)-> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, bleed_intensity_property_path, target_value, duration)
