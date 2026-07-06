extends EnemyState

# Player reference for global position tracking and a cooldown for how long to keep chasing the player while out of sight
var player: Player = null
var player_last_seen = 600

func _ready() -> void:
	super._ready()
	label = EnemyState.CHASING

# Set enemy speed to higher when chasing and set target to the players global position
func enter(payload: Dictionary = {}) -> void:
	enemy.current_speed = 5
	player = payload.get("player")
	target = player.global_position
	enemy.nav_agent.set_target_position(player.global_position)

func physics_process(_delta: float) -> void:
	# Make sure the raycast continously tracks the player while in range so the cooldown doesn't activate prematurely
	if player in enemy.peripheral_vision.get_overlapping_bodies():
		enemy.snap_vision(player)
	
	# Once the player is out of sight, continue to players last known position until cooldown elapses
	if not enemy.targeted_vision.is_colliding() or not enemy.targeted_vision.get_collider() is Player:
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

# Reset speed to normal and reset any other state dependent variables
func exit() -> void:
	enemy.current_speed = enemy.BASE_SPEED
	player = null
	player_last_seen = 600
	target = Vector3.ZERO
