class_name InteractableObject extends StaticBody3D

# Signal to send when item is interacted with
signal interacted

# Label to show when cursor collides
var ui_label

func _init() -> void:
	ui_label = "Debug"

func interaction() -> void:
	pass
