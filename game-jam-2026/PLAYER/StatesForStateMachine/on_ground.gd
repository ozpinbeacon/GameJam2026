extends State
## RAIL ON_GROUND STATE - Player standing still or moving while on the ground

const BLEND_RAMP_SPEED: float = 6
const BLEND_POS_SNAP_DISTANCE: float = 0.1
const PRINT_OUTPUT_COLOR: String = "aqua"

var current_blend_position: Vector2 = Vector2.ZERO

@export var foot_steps_audio_player: AudioStreamPlayer3D


#region Debug
func _debug(msg: String) -> void:
	print_rich("[color=%s]%s[/color]" % [PRINT_OUTPUT_COLOR, msg])
#endregion



#region Initialisation
func _ready() -> void:
	super._ready()
	state_name = "ON_GROUND"
	requires_physics_updates = true
#endregion



#region Enter/Exit
func enter_state() -> void:
	if state_machine.debug: _debug("ON_GROUND: Entered")


func exit_state() -> void:
	if state_machine.debug: _debug("ON_GROUND: Exiting")
	reset_in_air_buffer()
	exit_signal.emit()
#endregion



#region Physics
func physics_update(delta: float) -> void:
	if not state_active:
		return
		
	if not player.is_on_floor():
		apply_gravity(delta)
	handle_footstep_audio()
	move_character(delta)
	update_in_air_buffer(delta)
	
	if not transitioning:
		check_transitions()
#endregion



func move_character(delta: float)-> void:
	# Get the cameras basis
	var camera_basis: Basis = get_active_camera_rotation_basis()
	
	# Get the directional input vector
	var input_vector3: Vector3 = get_directional_input()
	
	# Set the players basis so they are facing the correct direction
	handle_player_orientation(camera_basis, input_vector3, delta)
	
	# Calculate and set the players horizontal velocity
	handle_player_horizontal_velocity(camera_basis, input_vector3, delta)
	
	# Handle blending between idle and run animations
	animate_character()
	
	player.set_up_direction(Vector3.UP)
	player.move_and_slide()
	
	clean_up_new_rotation_and_apply_to_mesh()


#region HANDLE PLAYER ORIENTATION
func handle_player_orientation(camera_basis: Basis, input_vector3: Vector3, delta: float)-> void:##Applies a slerped rotation value to players player.orientation.basis, taking into account directional input and active cameras rotation basis
	# Get the normalized Vector3 target taking directional input and the active cameras basis into account
	var look_at_target: Vector3 = get_look_at_target(camera_basis, input_vector3)
	
	# If the target is far enough away, calculate new basis and apply to players player.orientation.basis
	if look_at_target.length() > 0.001:
		player.orientation.basis = get_new_target_basis(look_at_target, delta)



func get_active_camera_rotation_basis()-> Basis:
	# Grab the currently active camera 3D
	var active_cam = get_viewport().get_camera_3d()
	
	# Return the basis
	return active_cam.global_transform.basis



func get_directional_input(return_as_Vector2: bool = false)-> Variant:## Returns a Vector3 representing the current directional keys being pressed
	# Get the horizontal movement direction by checking the directional inputs
	var input_vector2: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	# If requested return the Vector2 result
	if return_as_Vector2:
		return input_vector2
	
	# Convert the vector2 into a Vector 3 with y = 0 and return the result
	var input_vector3: Vector3 = Vector3(input_vector2.x, 0, input_vector2.y)
	return input_vector3



func get_look_at_target(camera_basis: Basis, input_vector3: Vector3)-> Vector3:
	"""
	Combines the cameras basis with any directional inputs to get 
	a look_at_target (ignoring the cameras y rotation)
	"""
	var camera_z: Vector3 = camera_basis.z
	var camera_x: Vector3 = camera_basis.x
	
	camera_z.y = 0
	camera_x.y = 0
	
	camera_z = camera_z.normalized()
	camera_x = camera_x.normalized()
	
	var look_at_target: Vector3 = -camera_x * input_vector3.x + -camera_z * input_vector3.z
	return look_at_target



func get_new_target_basis(look_at_target: Vector3, delta: float)-> Basis:
	"""
	'orientation' is a Transform3D in the players script. Its kind of a 
	dummy Transform3D used to apply rotational math to, so it can be 
	cleaned up (orthonormalized) of any errors or drifting values (which
	can happen over time when applying math to quaternions) before applying
	its value to the players mesh directly.
	
	This function takes the Vector3 Basis of player.orientation, converts
	it to Quaternions, then convert the targets basis to Quaternions (easier
	to do rotational math with quaternions and godot has a built in function
	for it called slerp) then uses slerp to smoothly rotate the value
	"""
	# Get the current rotation basis and convert it to Quaternions
	var basis_from: Basis = player.orientation.basis
	var q_from: Quaternion = basis_from.get_rotation_quaternion()
		
	# Get the target rotation basis and convert it to Quaternions
	var basis_to: Basis = Transform3D().looking_at(look_at_target, Vector3.UP).basis
	var q_to: Quaternion = basis_to.get_rotation_quaternion()
		
	# Use slerp to interpolate the next value to rotate towards to reach the target_basis
	return Basis(q_from.slerp(q_to, delta * player.ROTATION_INTERPOLATE_SPEED))


func clean_up_new_rotation_and_apply_to_mesh()-> void:
	# Cleans up the orientation value by ortonormalizing it(Removes any slight drifts and makes sure all angles are 90degrees apart from each other (Doing math on a basis can cause this over time)
	player.orientation.origin = Vector3()
	player.orientation = player.orientation.orthonormalized()
	
	# Apply the cleaned up orientation to the mesh
	player.player_model.global_transform.basis = player.orientation.basis

#endregion



func handle_player_horizontal_velocity(camera_basis: Basis, input_vector3: Vector3, delta: float)-> void:
	# Get the players current velocity and zero out on the y axis to prevent any up and down velocity from being applied
	var target_horizontal_velocity: Vector3 = player.velocity
	target_horizontal_velocity.y = 0
	
	# This line cancels out any accidental rotation along the cameras x axis so it has no little tilts or rotations we dont want
	camera_basis = camera_basis.rotated(camera_basis.x, -camera_basis.get_euler().x)
	
	# Multiply the camera basis by the inverse of the directional input vector3 to get the target direction
	var target_direction: Vector3 = camera_basis * input_vector3
	
	# Multiply the speed by the direction to get this frames target position to move towards
	var target_position: Vector3 = target_direction * player.SPEED
	
	# If their is no target direction set horizontal_velocity target to ZERO
	if target_direction.length() < 0.01:
		target_horizontal_velocity = Vector3.ZERO
	
	# Lerp the target horizontal velocity towards the target position
	else:
		target_horizontal_velocity = target_horizontal_velocity.lerp(target_position, player.ACCELERATION * delta)
	
	# Set the players velocity
	player.velocity.x = target_horizontal_velocity.x
	player.velocity.z = target_horizontal_velocity.z
	


func apply_gravity(delta: float)-> void:
	player.velocity += player.get_gravity() * delta



func animate_character()-> void:
	# Get the players current horizontal veloicty
	var horizontal_velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)

	# Get the horizontal velocity	
	var horizontal_direction: float = horizontal_velocity.length()
	
	# Divide it by the max velocity and clamp the result between 0.0 and 1.0
	var target_blend_amount: float = horizontal_direction/player.SPEED
	
	# Use the result to update the blend value in the animation tree
	target_blend_amount = clampf(target_blend_amount,0.0, 1.0)
	
	# Send the new blend position to the anim tree to be applied
	animation_tree.update_target_blend_value(target_blend_amount)



#region In Air Buffer
var in_air_buffer: float = 0.0
var is_in_air: bool = false
const IN_AIR_MAX_BUFFER_TIME: float = 0.5

func update_in_air_buffer(delta: float) -> void:
	if player.is_on_floor():
		in_air_buffer = 0.0
		is_in_air = false
		return
	in_air_buffer += delta
	is_in_air = in_air_buffer >= IN_AIR_MAX_BUFFER_TIME

func reset_in_air_buffer() -> void:
	is_in_air = false
	in_air_buffer = 0.0
#endregion



#region Footsteps SFX
func handle_footstep_audio() -> void:
	if player.velocity.length() <= 0.1:
		foot_steps_audio_player.stop()
		return
	var speed_ratio: float = player.velocity.length() / player.SPEED
	foot_steps_audio_player.pitch_scale = lerp(0.8, 1.2, clamp(speed_ratio, 0.0, 1.0))
	if not foot_steps_audio_player.playing:
		foot_steps_audio_player.play(2.0)
#endregion



#region Animation Blend
func handle_run_animation_blend(delta: float) -> void:
	
	# Get the players current horizontal veloicty
	var horizontal_velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)
	
	# Get the players current direction calculated from the velocity
	var horizontal_direction: float = horizontal_velocity.length()
	
	
	var target_blend_position: Vector2 = Vector2.ZERO
	if horizontal_direction > 0.1:
		target_blend_position = horizontal_velocity.normalized()

	## NOTE had to use the invers of target position y for it to allign with the blend trees y=-1 == left animation
	current_blend_position.x = move_toward(current_blend_position.x, target_blend_position.x, BLEND_RAMP_SPEED * delta)
	current_blend_position.y = move_toward(current_blend_position.y, target_blend_position.y, BLEND_RAMP_SPEED * delta)

	
	if current_blend_position.distance_to(target_blend_position) <= BLEND_POS_SNAP_DISTANCE:
		current_blend_position = target_blend_position
	
	#current_blend_position = snapped(current_blend_position, Vector2(0.1,0.1))
	
	#animation_tree.change_move_blend_value(Vector2(-current_blend_position.x, current_blend_position.y))
	animation_tree.change_move_blend_value(Vector2(Input.get_vector("left", "right", "up", "down").x, Input.get_vector("left", "right", "up", "down").y))

#endregion



#region Transitions
func check_transitions() -> void:
	if is_in_air:
		if state_machine.debug: _debug("ON_GROUND: Not on floor, transitioning to FALLING")
		state_machine.request_new_state("FALLING")
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		if state_machine.debug: _debug("ON_GROUND: Jump input, transitioning to JUMP")
		state_machine.request_new_state("JUMP")
		return
#endregion
