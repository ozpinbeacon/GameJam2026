extends Node3D
## Lantern ##

@onready var lantern_static_pivot_point: StaticBody3D = $LanternStaticPivotPoint
@onready var lantern_rigid_body: RigidBody3D = $LanternRigidBody

const frames_per_position_check: int = 2
var frame_counter: int = 0
var target_pos: Vector3


func _physics_process(delta: float) -> void:
	frame_counter += 1
	
	if frame_counter >= frames_per_position_check:
		frame_counter = 0
		update_lantern_position()
	
	if lantern_rigid_body.position != target_pos:
		var new_pos: Vector3
		new_pos = lerp(lantern_rigid_body.position, target_pos, delta)
		lantern_rigid_body.set_deferred("position", new_pos)
	


func update_lantern_position()-> void:
	# Freeze the rigid body so i can teleport it
	#lantern_rigid_body.set_deferred("sleep", true)
	
	# Get the location of the static pivot point
	target_pos = lantern_static_pivot_point.position
	
	#lantern_rigid_body.set_deferred("sleep", false)
