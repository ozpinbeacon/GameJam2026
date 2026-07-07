extends PlayerItem

func _init() -> void:
	self.ui_label = "Lantern"
	self.type = PlayerItem.ITEM_TYPES.Lantern

func interaction() -> void:
	self.interacted.emit(self.type)
	self.queue_free()
