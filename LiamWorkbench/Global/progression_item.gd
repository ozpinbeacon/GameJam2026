class_name ProgressionItem extends InteractableObject

# Send signal to game state with sender and remove from environment
func interaction() -> void:
	self.interacted.emit(self.ui_label)
	self.queue_free()
