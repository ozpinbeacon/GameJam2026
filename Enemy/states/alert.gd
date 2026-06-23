extends EnemyState

func _ready() -> void:
	super._ready()
	label = "Alert"

func enter(payload: Dictionary = {}) -> void:
	var alert_target = payload.get("alert_target")
	target = alert_target.global_position

func physics_process(delta: float) -> void:
	if enemy.vision.is_colliding and enemy.vision.get_collider() is Player:
		finished.emit(EnemyState.CHASING)

func exit() -> void:
	target = Vector3.ZERO
