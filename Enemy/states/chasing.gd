extends EnemyState

var player: Player = null
var player_last_seen = 600

func _ready() -> void:
	super._ready()
	label = "Chasing"

func enter(payload: Dictionary = {}) -> void:
	player = payload.get("player")
	target = player.global_position
	enemy.nav_agent.set_target_position(player.global_position)

func physics_process(_delta: float) -> void:
	if not enemy.vision.is_colliding() or not enemy.vision.get_collider() is Player:
		if target == Vector3.ZERO:
			target = player.global_position
			enemy.nav_agent.set_target_position(target)
		if player_last_seen > 0:
			player_last_seen -= 1
		else:
			finished.emit(EnemyState.PATROLLING)
	else:
		if target != Vector3.ZERO:
			target = Vector3.ZERO
		player_last_seen = 600
		enemy.nav_agent.set_target_position(player.global_position)

func exit() -> void:
	player = null
	player_last_seen = 600
	target = Vector3.ZERO
