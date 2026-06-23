extends EnemyState

var patrol_points: Array[Vector3] = [Vector3(21.8, 0, 23.5), Vector3(-23, 0, 23), Vector3(-23, 0, 0), Vector3(20, 0, 0), Vector3(20, 0, -20), Vector3(-20, 0, -20)]
var next_patrol_point = 0

func _ready() -> void:
	super._ready()
	label = "Patrolling"

func enter(payload: Dictionary = {}) -> void:
	Events.player_noise.connect(noise_heard)
	#enemy.animation_player.play("patrolling")
	enemy.nav_agent.set_target_position(patrol_points[next_patrol_point])

func physics_process(_delta: float) -> void:
	if enemy.nav_agent.is_target_reached():
		if next_patrol_point == 6:
			next_patrol_point = 0
		target = patrol_points[next_patrol_point]
		enemy.nav_agent.set_target_position(target)
		next_patrol_point += 1

func noise_heard(event: Dictionary) -> void:
	var event_type: Events.NoiseType = event["event_type"]
	var event_location: Vector3 = event["location"]
	var payload = {"location": event["location"]}
	
	match event_type:
		Events.NoiseType.YELL:
			finished.emit(EnemyState.INVESTIGATING, payload)
		Events.NoiseType.RUN:
			if enemy.global_position.distance_to(event_location) < 10:
				finished.emit(EnemyState.INVESTIGATING, payload)
		Events.NoiseType.WALK:
			if enemy.global_position.distance_squared_to(event_location) < 5:
				finished.emit(EnemyState.INVESTIGATING, payload)
		_:
			pass

func exit() -> void:
	target = Vector3.ZERO
