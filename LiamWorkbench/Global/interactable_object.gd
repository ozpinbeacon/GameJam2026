class_name InteractableObject extends StaticBody3D

# Signal to send when item is interacted with
signal interacted

# Label to show when cursor collides
var ui_label

# Set the label to the node name by default
func _ready() -> void:
	ui_label = self.get_name()

func interaction() -> void:
	pass
