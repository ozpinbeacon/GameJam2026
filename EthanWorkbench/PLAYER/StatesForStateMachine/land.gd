extends State
## LAND STATE - Player landing

const PRINT_OUTPUT_COLOR: String = "navy_blue"
const LANDING_ANIMATION_TIME: float = 2.0333 ## Set to match the animation in seconds, allows transitioning to IDLE state once animation is complete

var landing_animation_complete: bool = false## Not used if player transitions straight to moving or jumping or sliding but before transitioning to IDLE this gets used
var animation_timer: SceneTreeTimer

@export var land_SFX: CharacterSFXPlayer


#region Debug
func _debug(msg: String) -> void:
	print_rich("[color=%s]%s[/color]" % [PRINT_OUTPUT_COLOR, msg])
#endregion



#region Initialisation
func _ready() -> void:
	super._ready()
	state_name = "LAND"
	requires_physics_updates = true
	requires_input_buffer = true
	#animation_timer.wait_time = LANDING_ANIMATION_TIME
	#animation_timer.timeout.connect(_on_landing_animation_complete)
#endregion



#region Enter/Exit
func enter_state() -> void:
	if state_machine.debug: _debug("LAND: Entered")
	if land_SFX:
		land_SFX.play()
	

	landing_animation_complete = false ## Reset back to default
	# Play the land animation
	animation_tree.fire_one_shot(state_name)
	animation_timer = get_tree().create_timer(LANDING_ANIMATION_TIME)
	animation_timer.timeout.connect(_on_landing_animation_complete)
	

func exit_state() -> void:
	if state_machine.debug: _debug("LAND: Exiting")
	animation_tree.fade_out_one_shot(state_name)
	landing_animation_complete = false ## Reset back to default
	exit_signal.emit()
#endregion



#region Physics
func physics_update(delta: float) -> void:
	if not state_active:
		return
	if not player.is_on_floor():
		apply_gravity(delta)
	move_character(delta)
	check_transition()
#endregion




#region Movement Helpers
func apply_gravity(delta: float)-> void:
	player.velocity += player.get_gravity() * delta



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



#region HANDLE PLAYER player.orientation
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

#endregion



func _on_landing_animation_complete()-> void:
	if state_machine.current_state != self:
		return
	landing_animation_complete = true



#region Transitions
func check_transition() -> void:
	if not state_active:
		return
	#if state_machine.debug: _debug("LAND: Checking transitions")

	if not player.is_on_floor():
		if state_machine.debug: _debug("LAND: Transitioning to FALLING")
		state_machine.request_new_state("FALLING")
		return
	
	# Check for any stored inputs in the input buffer first
	if state_machine.stored_player_input != "":
		var buffered = state_machine.stored_player_input
		# Wipes the stored input ready for next time it needs to be used
		state_machine.clear_buffered_input()
		# Transition to the state required by the buffered input
		state_machine.request_new_state(buffered)
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		if state_machine.debug: _debug("LAND: Jump input, transitioning to JUMP")
		state_machine.request_new_state("JUMP")
		return
	
	# Get the horizontal movement direction by checking the directional inputs
	var input_vector2: Vector2 = Input.get_vector("left", "right", "up", "down")
	#If player is moving transition to ON GROUND state otherwise only transition to ON GROUND state if landing animation has finished
	if player.is_on_floor() and landing_animation_complete or input_vector2.length() != 0:
		if state_machine.debug: _debug("LAND: Transitioning to ON_GROUND")
		state_machine.request_new_state("ON_GROUND")
		return
#endregion
