extends PlayerState

# TODO Add stamina resource

func _ready() -> void:
	super._ready()
	label = PlayerState.RUNNING

# Increase speed for running
func enter(_dict = {}) -> void:
	player.acceleration *= player.RUN_ACCEL
	player.speed = player.RUN_SPEED

func physics_process(delta: float) -> void:
	# Allow jumping while running
	if Input.is_action_pressed("jump"):
		finished.emit(PlayerState.JUMPING)
	
	# Once sprint is released, transition to appropriate state	
	if not Input.is_action_pressed("sprint"):
		if player.velocity.x == 0 and player.velocity.z == 0:
			finished.emit(PlayerState.IDLE)
		else:
			finished.emit(PlayerState.WALKING)
	
	# If stamina exhausts, force walking until it replenishes
	if player.stamina <= 0:
		player.stamina_depleted = true
		finished.emit(PlayerState.WALKING)
	elif not player.stamina_inf:
		player.stamina -= 15 * delta	
	
	# If pills are currently in effect, add speed multiplier
	if player.p_speed_on:
		player.speed = player.RUN_SPEED * player.P_SPEED
	
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player._lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	# Noise emission
	Events.player_noise.emit({"event_type": Events.NoiseType.RUN, "location": player.global_position})

#func exit() -> void:
	# Play some animation
