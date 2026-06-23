class_name Enemy extends CharacterBody3D

const SPEED = 2

@onready var fsm = $StateMachine
@onready var nav_agent = $NavigationAgent3D
@onready var vision = $RayCast3D
	
func _physics_process(delta) -> void:
	velocity = Vector3.ZERO
	
	if vision.is_colliding() and vision.get_collider() is Player:
		fsm._transition_to_next_state(EnemyState.CHASING, {"player": vision.get_collider()})
	
	fsm.state.physics_process(delta)

	if fsm.state.label in [EnemyState.PATROLLING, EnemyState.INVESTIGATING, EnemyState.CHASING]:
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_position).normalized() * SPEED

	rotation.y = lerp(rotation.y, atan2(-fsm.state.target.x, -fsm.state.target.z), 0.75 * delta)
	
	move_and_slide()

func get_current_target() -> Vector3:
	return fsm.state.target
