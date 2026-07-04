extends EnemyState

func _ready() -> void:
	super._ready()
	label = EnemyState.ALERT

# When entering state, set the target to what ever triggered the alert
func enter(payload: Dictionary = {}) -> void:
	var alert_target = payload.get("alert_target")
	target = alert_target.global_position
	
# If the player is within sight, transition to chasing, otherwise turn to face target
func physics_process(delta: float) -> void:
	if enemy.targeted_vision.is_colliding and enemy.targeted_vision.get_collider() is Player:
		finished.emit(EnemyState.CHASING)
	else:
		enemy.rotation.y = lerp(enemy.rotation.y, atan2(-target.x, -target.z), 0.75 * delta)

# Reset target
func exit() -> void:
	target = Vector3.ZERO
