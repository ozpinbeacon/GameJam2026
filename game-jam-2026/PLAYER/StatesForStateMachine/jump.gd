extends State
## JUMP STATE - Player jumping


const PRINT_OUTPUT_COLOR: String = "deep_sky_blue"
const CALL_ADD_VELOCITY_TIME: float = 0.05
const MAX_IN_AIR_BUFFER_TIME: float = 0.2 ## Player is considered in air once buffer reaches this value

var in_air_buffer_time: float = 0.0## Increase by delta each physics frame
var in_air_buffer_timed_out: bool = false## Set to true once in_air_buffer reaches the value of MAX_IN_AIR_BUFFER
var jump_velocity_added: bool = false

@export var jump_SFX: CharacterSFXPlayer
@export var footsteps_audio_player: AudioStreamPlayer3D



#region Debug
func _debug(msg: String) -> void:
	print_rich("[color=%s]%s[/color]" % [PRINT_OUTPUT_COLOR, msg])
#endregion


#region Initialisation
func _ready() -> void:
	super._ready()
	state_name = "JUMP"
	requires_physics_updates = true
#endregion


#region Enter/Exit
func enter_state() -> void:
	if state_machine.debug: _debug("JUMP: Entered")
	
	# Reset the buffer upon entering state
	in_air_buffer_timed_out = false
	
	# Stop footsteps and play the jump SFX
	if footsteps_audio_player.playing:
		footsteps_audio_player.stop()
	if jump_SFX:
		jump_SFX.play()
	

	# Play the jump animation
	animation_tree.fire_one_shot(state_name)
	
	# Start the timer to call the jump velocity on timeout (to match up with the animation)
	get_tree().create_timer(CALL_ADD_VELOCITY_TIME).timeout.connect(add_jump_velocity)



func exit_state() -> void:
	if state_machine.debug: _debug("JUMP: Exiting")
	jump_velocity_added = false
	exit_signal.emit()
#endregion


#region Jump Velocity
func add_jump_velocity() -> void:
	if not state_active:
		return
	if state_machine.debug: _debug("JUMP: Adding jump velocity")
	player.velocity.y = player.JUMP_VELOCITY
	jump_velocity_added = true
#endregion


#region Physics
func physics_update(delta: float) -> void:
	if not state_active:
		return
	apply_gravity(delta)
	move_character(delta)
	handle_in_air_buffer(delta)
	if not transitioning:
		check_transitions()
#endregion


#region Movement helpers
func move_character(delta: float)-> void:
	# Get the cameras basis
	var camera_basis: Basis = get_active_camera_rotation_basis()
	
	# Get the directional input vector
	var input_vector3: Vector3 = get_directional_input()
	
	# Set the players basis so they are facing the correct direction
	handle_player_orientation(camera_basis, input_vector3, delta)
	
	# Calculate and set the players horizontal velocity
	handle_player_horizontal_velocity(camera_basis, input_vector3, delta)
	
	player.set_up_direction(Vector3.UP)
	player.move_and_slide()
	
	player.orientation.origin = Vector3()
	player.orientation = player.orientation.orthonormalized()
	player.player_model.global_transform.basis = player.orientation.basis



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
	var camera_z: Vector3 = camera_basis.z
	var camera_x: Vector3 = camera_basis.x
	
	camera_z.y = 0
	camera_x.y = 0
	
	camera_z = camera_z.normalized()
	camera_x = camera_x.normalized()
	
	var look_at_target: Vector3 = -camera_x * input_vector3.x + -camera_z * input_vector3.z
	return look_at_target



func get_new_target_basis(look_at_target: Vector3, delta: float)-> Basis:
	# Get the current rotation basis and convert it to Quaternions
	var basis_from: Basis = player.orientation.basis
	var q_from: Quaternion = basis_from.get_rotation_quaternion()
		
	# Get the target rotation basis and convert it to Quaternions
	var basis_to: Basis = Transform3D().looking_at(look_at_target, Vector3.UP).basis
	var q_to: Quaternion = basis_to.get_rotation_quaternion()
		
	# Use slerp to interpolate the next value to rotate towards to reach the target_basis
	return Basis(q_from.slerp(q_to, delta * player.ROTATION_INTERPOLATE_SPEED))
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
	if player.velocity.y > 0:
		player.velocity += player.get_gravity() * player.JUMP_GRAVITY_MULTIPLIER * delta
	else:
		player.velocity += player.get_gravity() * player.FALL_GRAVITY_MULTIPLIER * delta



func handle_in_air_buffer(delta)-> void:
	# Provide a slight delay before being able to transition straight to LAND state
	if not in_air_buffer_timed_out:
		in_air_buffer_time += delta
		if in_air_buffer_time == MAX_IN_AIR_BUFFER_TIME:
			in_air_buffer_timed_out = true
#endregion


#region Transitions
func check_transitions() -> void:
	if player.is_on_floor() and in_air_buffer_timed_out:
		if state_machine.debug: _debug("JUMP: Landed, transitioning to LAND")
		state_machine.request_new_state("LAND")
		return
	if player.is_on_floor() and jump_velocity_added and player.velocity.y == 0:
		if state_machine.debug: _debug("JUMP: Still on ground, ON_GROUND")
		state_machine.request_new_state("ON_GROUND")
		return
	
	if player.velocity.y <= 0 and jump_velocity_added:
		if state_machine.debug: _debug("JUMP: Falling, transitioning to FALLING")
		state_machine.request_new_state("FALLING")
		return
		
#endregion
