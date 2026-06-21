extends Label

@export var player := NodePath("/root/Main/Player")
@onready var _player := get_node(player)

func _process(_delta: float) -> void:
	text = "Velocity X" + str(_player.velocity.x)
	text += "Velocity Y" + str(_player.velocity.y)
	text += "Velocity Z" + str(_player.velocity.z)
