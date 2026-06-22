extends InteractableObject

# Instance variables
func _ready():
	self.label = "Torch"
	self.object_type = ObjectType.Player
	super._ready()
	self.player_item = self.player.get_node("Hand/Torch")

# When interacted with, remove world item and add player item
func interact() -> void:
	self.player_item.show()
	self.player.has_flashlight = true
	super.interact()
