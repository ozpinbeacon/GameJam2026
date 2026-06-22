extends Label

# Debug label to show current velocities and cursor information
@export var player := NodePath("/root/Global/Main/Player")
@export var game_state := NodePath("/root/Global/Main/GameState")
@onready var _player := get_node(player)
@onready var _game_state := get_node(game_state)

func _process(_delta: float) -> void:
	text = "Velocity X" + str(_player.velocity.x) + "\n"
	text += "Velocity Y" + str(_player.velocity.y) + "\n"
	text += "Velocity Z" + str(_player.velocity.z) + "\n"
	text += "\n"
	text += "Player State: " + _player.get_state() + "\n"
	text += "Game State: " + _game_state.get_state() + "\n"
	text += "\n"
	text += "Interactable item? " + str(_player.cursor.is_colliding() and _player.cursor.get_collider() is InteractableObject) + "\n"
	text += "\tInteractable item: " + str(_player.cursor.get_collider().name) if _player.cursor.is_colliding() and _player.cursor.get_collider() is InteractableObject else "None"
