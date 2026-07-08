extends EnvironmentalObject

# Animation player
@onready var animation_player = $AnimationPlayer

# Play the animation when the player addeds an item to the altar
func item_added() -> void:
	animation_player.play("item_added")

# Emit interaction signal
func interaction() -> void:
	self.interacted.emit()
