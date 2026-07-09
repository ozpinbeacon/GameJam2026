extends EnvironmentalObject

# Animation player
@onready var animation_player = $AnimationPlayer

# Items currently on the alter
var current_items: Array[String] = []

# Play the animation when the player addeds an item to the altar
func item_added(added_item) -> void:
	animation_player.play("item_added")
	self.current_items.append(added_item)

# Emit interaction signal
func interaction() -> void:
	self.interacted.emit()
