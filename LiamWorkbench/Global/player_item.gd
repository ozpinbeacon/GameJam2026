class_name PlayerItem extends InteractableObject

# Any items we can think of
enum ITEM_TYPES {Lantern, Pills, HolyWater, MBWand}

var type: ITEM_TYPES

# Emit signal with sender and remove from enviroment
func interaction() -> void:
	self.interacted.emit(self.type)
	self.queue_free()
