extends Label

@export var player := NodePath("/root/Main/Player")
@export var cursor := NodePath("/root/Main/Player/Head/Cursor")
@onready var _player := get_node(player)
@onready var _cursor := get_node(cursor)

func _process(_delta: float) -> void:
	text = "Velocity X" + str(_player.velocity.x) + "\n"
	text += "Velocity Y" + str(_player.velocity.y) + "\n"
	text += "Velocity Z" + str(_player.velocity.z) + "\n"
	text += "\n"
	text += "State: " + _player.get_state()
	text += "\n"
	text += "Interactable item?" + str(_player.cursor.is_colliding())
	text += "Interactable item: " + str(_player.cursor.get_collider()) if _player.cursor.is_colliding() else "None"
