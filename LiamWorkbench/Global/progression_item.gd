class_name ProgressionItem extends InteractableObject

func interaction() -> void:
	self.interacted.emit()
	self.queue_free()
