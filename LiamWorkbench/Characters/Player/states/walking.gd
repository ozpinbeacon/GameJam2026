extends PlayerState

const CAMERA_BOB_FREQUENCY = 14
const CAMERA_BOB_INTENSITY = 0.1

func _ready() -> void:
	super._ready()
	label = PlayerState.WALKING

# Standard speed
func enter(_dict = {}) -> void:
	player.speed = player.WALK_SPEED

# Allow player to crouch while walking
func input(event) -> void:
	if event.is_action_pressed("crouch"):
		get_viewport().set_input_as_handled()
		finished.emit(PlayerState.CROUCHING)

# Allow sprinting and jumping while walking
func physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		finished.emit(PlayerState.JUMPING)
	elif Input.is_action_pressed("sprint") and player.stamina > 0 and not player.stamina_depleted: #Only allow sprinting if not depleted and above 0
		finished.emit(PlayerState.RUNNING)
	
	# If pills are currently in effect, add speed multiplier
	if player.p_speed_on:
		player.speed = player.WALK_SPEED * player.P_SPEED
	
	player._player_movement(delta)
	
	# Camera bob
	player._camera_bob(delta)
	
	# Set to idle if not moving, otherwise emit noise
	if player.velocity.x == 0 and player.velocity.z == 0:
		finished.emit(PlayerState.IDLE)
	else:
		Events.player_noise.emit({"event_type": Events.NoiseType.WALK, "location": player.global_position})

#func exit() -> void:
#	# Play an animation
