extends EnemyState

func _ready() -> void:
	super._ready()
	label = EnemyState.INVESTIGATING

# Increase speed while investigating and set target to the location of the instigating event
func enter(payload: Dictionary = {}) -> void:
	enemy.current_speed = 5
	target = payload.get("location")
	enemy.nav_agent.set_target_position(target)

# Once enemy reaches the location, assuming they didn't encounter the player, return to patrolling
func physics_process(_delta: float) -> void:
	if enemy.nav_agent.is_target_reached():
		finished.emit(EnemyState.PATROLLING)

# Reset speed
func exit() -> void:
	enemy.current_speed = enemy.BASE_SPEED
	target = Vector3.ZERO
