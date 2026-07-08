class_name Enemy extends CharacterBody3D

signal player_caught

# Enemy speed variables
const BASE_SPEED = 2
var current_speed = BASE_SPEED

# Changes behaviour to ignore player
@export var debug = false

# Children references
@onready var fsm = $StateMachine
@onready var nav_agent = $NavigationAgent3D
@onready var peripheral_vision = $Vision/Peripheral
@onready var targeted_vision = $Vision/Targeted
@onready var body = $CollisionShape3D

# Reference to the player for location tracking
@export var player: Node

# When an object enters the peripheral vision, snap raycast to the object
func _ready() -> void:
	peripheral_vision.body_entered.connect(_snap_vision)

func _physics_process(delta) -> void:
	velocity = Vector3.ZERO
	
	if not self.get_last_slide_collision() == null and self.get_last_slide_collision().get_collider() is Player:
		player_caught.emit()
	
	# If the raycast is colliding with the player, transition to CHASING state
	if targeted_vision.is_colliding() and targeted_vision.get_collider() is Player:
		player = targeted_vision.get_collider()
		fsm._transition_to_next_state(EnemyState.CHASING, {"player": player})
	
	# Current state physics process
	fsm.state.physics_process(delta)

	# Enemy navigation
	if fsm.state.label in [EnemyState.PATROLLING, EnemyState.INVESTIGATING, EnemyState.CHASING] and not debug:
		# Get next navigation point
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_position).normalized() * current_speed
		
		# Make enemy look where they're going
		if next_nav_point != global_position:
			var direction_to_look = global_position.direction_to(Vector3(next_nav_point.x, global_position.y, next_nav_point.z))
			var target: Basis = Basis.looking_at(direction_to_look)
		
			self.basis = self.basis.slerp(target, 0.05)
	
	move_and_slide()

# Snap raycast to object in periphery
func _snap_vision(body) -> void:
	targeted_vision.target_position = targeted_vision.to_local(body.global_position)

# What is the current objective of the enemy
func get_current_target() -> Vector3:
	return fsm.state.target
	
