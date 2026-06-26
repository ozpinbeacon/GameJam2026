extends EnemyState

func _ready() -> void:
	super._ready()
	label = EnemyState.INVESTIGATING

func enter(payload: Dictionary = {}) -> void:
	enemy.current_speed = 5
	target = payload.get("location")
	enemy.nav_agent.set_target_position(target)

func physics_process(_delta: float) -> void:
	if enemy.nav_agent.is_target_reached():
		finished.emit(EnemyState.PATROLLING)

func exit() -> void:
	enemy.current_speed = enemy.BASE_SPEED
	target = Vector3.ZERO
