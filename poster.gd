class_name Poster extends InteractableObject

# Set as a Progression type item
func _ready():
	self.label = "Poster"
	self.object_type = ObjectType.Progression
	super._ready()
