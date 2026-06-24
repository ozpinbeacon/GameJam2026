class_name Enemy extends CharacterBody3D

const BASE_SPEED = 2
var current_speed = BASE_SPEED

@export var debug = false

@onready var fsm = $StateMachine
@onready var nav_agent = $NavigationAgent3D
@onready var peripheral_vision = $Vision/Peripheral
@onready var targeted_vision = $Vision/Targeted

@export var player: Node

func _ready() -> void:
	peripheral_vision.body_entered.connect(snap_vision)

func _physics_process(delta) -> void:
	velocity = Vector3.ZERO
	
	if targeted_vision.is_colliding() and targeted_vision.get_collider() is Player:
		player = targeted_vision.get_collider()
		fsm._transition_to_next_state(EnemyState.CHASING, {"player": player})
	
	fsm.state.physics_process(delta)

	if fsm.state.label in [EnemyState.PATROLLING, EnemyState.INVESTIGATING, EnemyState.CHASING] and not debug:
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_position).normalized() * current_speed
		
		if next_nav_point != global_position:
			var direction_to_look = global_position.direction_to(Vector3(next_nav_point.x, global_position.y, next_nav_point.z))
			var target: Basis = Basis.looking_at(direction_to_look)
		
			self.basis = self.basis.slerp(target, 0.05)
	
	move_and_slide()

func get_current_target() -> Vector3:
	return fsm.state.target

func snap_vision(body) -> void:
	targeted_vision.target_position = targeted_vision.to_local(body.global_position)
	
