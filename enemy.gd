class_name Enemy extends CharacterBody3D

enum State {PATROLLING, CHASING}

var enemy_state: State = State.PATROLLING
const SPEED = 10

var patrol_points: Array[Vector3] = [Vector3(21.8, 0, 23.5), Vector3(-23, 0, 23), Vector3(-23, 0, 0), Vector3(20, 0, 0), Vector3(20, 0, -20), Vector3(-20, 0, -20)]
var next_patrol_point = 0

var player_last_seen = 600
var player = null
@export var player_path: NodePath = NodePath("/root/Global/Main/Player")

@onready var nav_agent = $NavigationAgent3D
@onready var vision = $RayCast3D

func _ready() -> void:
	player = get_node(player_path)
	nav_agent.set_target_position(patrol_points[next_patrol_point])
	
func _physics_process(_delta) -> void:
	velocity = Vector3.ZERO
	
	if vision.is_colliding() and vision.get_collider() is Player:
		enemy_state = State.CHASING
		nav_agent.set_target_position(player.global_position)
		player_last_seen = 600
	else:
		if enemy_state == State.CHASING:
			if player_last_seen > 0:
				player_last_seen -= 1
			else:
				enemy_state = State.PATROLLING
				nav_agent.set_target_position(patrol_points[next_patrol_point])
	
	if nav_agent.is_target_reached():
		if enemy_state == State.PATROLLING:
			if next_patrol_point == 6:
				next_patrol_point = 0
			nav_agent.set_target_position(patrol_points[next_patrol_point])
			next_patrol_point += 1

	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED
	
	look_at(next_nav_point, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	
	move_and_slide()

func get_current_target() -> Vector3:
	if enemy_state == State.CHASING:
		return player.global_position
	else:
		return patrol_points[next_patrol_point]

func get_state() -> String:
	match enemy_state:
		State.PATROLLING:
			return "Patrolling"
		State.CHASING:
			return "Chasing"
		_:
			return "Unknown"
