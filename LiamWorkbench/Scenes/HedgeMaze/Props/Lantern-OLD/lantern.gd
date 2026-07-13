extends PlayerItem

# Set the ui label and the 'type' of item
func _ready() -> void:
	self.ui_label = "Lantern"
	self.type = PlayerItem.ITEM_TYPES.Lantern
