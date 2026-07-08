extends PlayerItem

# Set the ui label and the 'type' of item
func _init() -> void:
	self.ui_label = "Lantern"
	self.type = PlayerItem.ITEM_TYPES.Lantern

# Emit signal with sender and remove from enviroment
func interaction() -> void:
	self.interacted.emit(self.type)
	self.queue_free()
