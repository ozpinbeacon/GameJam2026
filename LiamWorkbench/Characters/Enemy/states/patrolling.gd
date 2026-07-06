extends EnemyState

#var patrol_points: Array[Vector3] = [Vector3(65.6, 0, -77.661), Vector3(-61.59, 0, -42.146), Vector3(0, 0, 0), Vector3(-52.951, 0, 59.021)]
# Debug patrol points to test pathfinding
var patrol_points: Array[Vector3] = [Vector3(0, 0, 22.763), Vector3(-8.793, 0, -0.123), Vector3(0, 0, 12.348), Vector3(0, 0, -25.69)]
var next_patrol_point = 0

func _ready() -> void:
	super._ready()
	label = EnemyState.PATROLLING

# Connect to player noise signal and set initial patrol point
func enter(payload: Dictionary = {}) -> void:
	Events.player_noise.connect(noise_heard)
	#enemy.animation_player.play("patrolling")
	enemy.nav_agent.set_target_position(patrol_points[next_patrol_point])

# Cycle through patrol points
func physics_process(_delta: float) -> void:
	if enemy.nav_agent.is_target_reached():
		if next_patrol_point == 4:
			next_patrol_point = 0
		target = patrol_points[next_patrol_point]
		enemy.nav_agent.set_target_position(target)
		next_patrol_point += 1

# Player noise function, different noises have different ranges for whether the enemy will investigate or not
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

# Disconnect signal
func exit() -> void:
	Events.player_noise.disconnect(noise_heard)
	target = Vector3.ZERO
