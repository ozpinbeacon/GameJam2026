extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.CROUCHING

# Set player speed to be slower while crouching
func enter(_dict = {}) -> void:
	player.acceleration = player.CROUCH_SPEED
	player.speed = player.CROUCH_SPEED
	player.animation_player.play("CROUCH")
	player.crouched = true

# Exit crouch if toggled again and go to appropriate state for movement
func input(event) -> void:
	if event.is_action_pressed("crouch"):
		get_viewport().set_input_as_handled()
		if player.velocity.x == 0 and player.velocity.z == 0:
			finished.emit(PlayerState.IDLE)
		else:
			finished.emit(PlayerState.WALKING)

# Standard movement and noise emission
func physics_process(delta: float) -> void:
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player._lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	if not (player.velocity.x == 0 and player.velocity.z == 0):
		Events.player_noise.emit({"event_type": Events.NoiseType.CROUCH_WALK, "location": player.global_position})

func exit() -> void:
	# Play an animation
	player.animation_player.play("UNCROUCH")
	player.crouched = false
