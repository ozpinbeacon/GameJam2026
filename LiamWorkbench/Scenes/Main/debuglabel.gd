extends Label

# Debug label to show current velocities and cursor information
@export var player := NodePath("/root/Global/Main/Player")
@export var enemy := NodePath("/root/Global/Main/Enemy")
@export var game_state := NodePath("/root/Global/Main/GameState")
@onready var _player := get_node(player)
@onready var _game_state := get_node(game_state)
@onready var _enemy := get_node(enemy)

func _process(_delta: float) -> void:
	text = "Game State: " + _game_state.get_state() + "\n"
	text += "\n"
	text += "Player State: " + _player.fsm.state.label + "\n"
	text += "Player Position: " + str(_player.global_position) + "\n"
	text += "Velocity X" + str(_player.velocity.x) + "\n"
	text += "Velocity Y" + str(_player.velocity.y) + "\n"
	text += "Velocity Z" + str(_player.velocity.z) + "\n"
	text += "\n"
	text += "Enemy State: " + _enemy.fsm.get_state() + "\n"
	text += "Enemy Player Last Seen: " + str(_enemy.fsm.state.player_last_seen if _enemy.fsm.state.label == EnemyState.CHASING else "N/A") + "\n"
	text += "Enemy Target: " + str(_enemy.nav_agent.get_next_path_position()) + "\n"
	text += "Velocity X" + str(_enemy.velocity.x) + "\n"
	text += "Velocity Y" + str(_enemy.velocity.y) + "\n"
	text += "Velocity Z" + str(_enemy.velocity.z) + "\n"
	text += "\n"
	text += "Interactable item? " + str(_player.cursor.is_colliding() and _player.cursor.get_collider() is InteractableObject) + "\n"
	text += "\tInteractable item: " + str(_player.cursor.get_collider().name) if _player.cursor.is_colliding() and _player.cursor.get_collider() is InteractableObject else "None"
