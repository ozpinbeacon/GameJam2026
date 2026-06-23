extends State
## SLIDE STATE - Player sliding

@onready var collision_shape_3d: CollisionShape3D = $"../../CollisionShape3D"
@onready var slide_collision_shape_3d: CollisionShape3D = $"../../SlideCollisionShape3D"
@onready var dust_trail_particles: GPUParticles3D = $"../../KeithV4/ModifiedArmature/Skeleton3D/Keith/DustTrailParticles"
@onready var slide_sfx: AudioStreamPlayer3D = $"../../SlideSFX"

const SLIDE_SPEED: float = 16.0
const SLIDE_DURATION: float = 1.2
const SLIDE_DECELERATION: float = 10.0

var slide_timer: float = 0.0
var slide_direction: Vector3 = Vector3.ZERO

#region Debug
const PRINT_OUTPUT_COLOR: String = "yellow"
func _debug(msg: String) -> void:
	print_rich("[color=%s]%s[/color]" % [PRINT_OUTPUT_COLOR, msg])
#endregion

#region Initialisation
func _ready() -> void:
	super._ready()
	state_name = "SLIDE"
	requires_physics_updates = true
#endregion

#region Enter/Exit
func enter_state() -> void:
	if state_machine.debug: _debug("SLIDE: Entered")
	slide_timer = 0.0
	if player.foot_steps.playing:
		player.foot_steps.stop()
	
	slide_sfx.play()
	
	apply_initial_slide_velocity()
	
	toggle_collision_shapes()
	
	dust_trail_particles.emitting = true
	

	# Play the slide animation
	animation_tree.fire_one_shot(state_name)

func exit_state() -> void:
	if state_machine.debug: _debug("SLIDE: Exiting")
	dust_trail_particles.emitting = false
	slide_sfx.stop()
	animation_tree.fade_out_one_shot(state_name)
	toggle_collision_shapes()
	exit_signal.emit()
#endregion

#region Physics
func physics_update(delta: float) -> void:
	if not state_active:
		return
		
	apply_gravity(delta)
	
	slide_timer += delta
	
	apply_horizontal_velocity(delta)
	
	player.move_and_slide()
	
	if not transitioning:
		check_transitions()
#endregion


func toggle_collision_shapes()-> void:
	"""
	Toggles the players collision shape and their slide collision shape
	Note: One should always be disabled when starting the game. This
	function is called when entering slide state and then called again
	when exiting to a new state
	"""
	if state_machine.debug: print("Toggling collision shapes. CURRENT STATUS:")
	if state_machine.debug: print("SLIDE: collision_shape_3D.disabled: ", collision_shape_3d.disabled)
	if state_machine.debug: print("SLIDE: slide_collision_shape_3D.disabled: ", slide_collision_shape_3d.disabled)
	collision_shape_3d.disabled = not collision_shape_3d.disabled
	slide_collision_shape_3d.disabled = not slide_collision_shape_3d.disabled
	print()
	if state_machine.debug: print("Collision shapes toggled. UPDATED STATUS:")
	if state_machine.debug: print("SLIDE: collision_shape_3D.disabled: ", collision_shape_3d.disabled)
	if state_machine.debug: print("SLIDE: slide_collision_shape_3D.disabled: ", slide_collision_shape_3d.disabled)



#region Movement Helpers
func apply_initial_slide_velocity()-> void:
	if player.velocity.length() >= 0.1:
		slide_direction = Vector3(player.velocity.x, 0, player.velocity.z).normalized()
	else:
		slide_direction = -player.mesh.transform.basis.z
	player.velocity.x = slide_direction.x * SLIDE_SPEED
	player.velocity.z = slide_direction.z * SLIDE_SPEED



func apply_gravity(delta: float)-> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta



func apply_horizontal_velocity(delta)-> void:
	# Get the players current velocity
	var current_slide_velocity: Vector3 = Vector3(player.velocity.x, 0, player.velocity.z)
	
	# Calculate the players new velocity (slowly decelerates over time)
	var decelerated_velocity: Vector3 = current_slide_velocity.move_toward(Vector3.ZERO, SLIDE_DECELERATION * delta)
	
	# Apply players horizontal velocity
	player.velocity.x = decelerated_velocity.x
	player.velocity.z = decelerated_velocity.z
#endregion



#region Transitions
func check_transitions() -> void:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		if state_machine.debug: _debug("IDLING: Jump input, transitioning to JUMP")
		state_machine.request_new_state("SLIDE_JUMP")
		return
		
	var horizontal_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	if slide_timer >= SLIDE_DURATION or horizontal_speed < 1.0:
		if not player.is_on_floor():
			if state_machine.debug: _debug("SLIDE: Not on floor, transitioning to FALLING")
			state_machine.request_new_state("FALLING")
			return

		else:
			if state_machine.debug: _debug("SLIDE: Transitioning to ON_GROUND")
			state_machine.request_new_state("ON_GROUND")
			return			
#endregion
