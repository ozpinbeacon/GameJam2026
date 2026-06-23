class_name Enemy extends CharacterBody3D

const BASE_SPEED = 2
var current_speed = BASE_SPEED

@onready var fsm = $StateMachine
@onready var nav_agent = $NavigationAgent3D
@onready var vision = $Vision
@onready var debug_vision = $Vision/Debug/MeshInstance3D

@export var player: Node
	
func _physics_process(delta) -> void:
	velocity = Vector3.ZERO
	
	if vision.has_overlapping_bodies() and vision.get_overlapping_bodies().any(func(body): return is_instance_of(body, Player)):
		var player_index = vision.get_overlapping_bodies().find_custom(func(body): return is_instance_of(body, Player))
		player = vision.get_overlapping_bodies().get(player_index)
		fsm._transition_to_next_state(EnemyState.CHASING, {"player": player})
	
	fsm.state.physics_process(delta)

	if fsm.state.label in [EnemyState.PATROLLING, EnemyState.INVESTIGATING, EnemyState.CHASING]:
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_position).normalized() * current_speed
		
		if next_nav_point != global_position:
			var direction_to_look = global_position.direction_to(Vector3(next_nav_point.x, global_position.y, next_nav_point.z))
			var target: Basis = Basis.looking_at(direction_to_look)
		
			self.basis = self.basis.slerp(target, 0.05)
	
	move_and_slide()

func get_current_target() -> Vector3:
	return fsm.state.target
