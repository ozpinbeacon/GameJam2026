extends PlayerItem

# Set the ui label and the 'type' of item
func _ready() -> void:
	self.ui_label = "Pills"
	self.type = PlayerItem.ITEM_TYPES.Pills
