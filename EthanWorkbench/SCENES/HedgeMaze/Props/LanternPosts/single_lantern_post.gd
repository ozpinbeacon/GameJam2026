extends Node3D
## Single Lantern Post ##

@export var omni_light_3d: OmniLight3D


func _ready() -> void:
	connect_signals()

func connect_signals()-> void:
	SignalBus.connect_signal(self, "change_all_lanterns_color")

func _on_change_all_lanterns_color(color: Color)-> void:
	omni_light_3d.set("light_color", color)
