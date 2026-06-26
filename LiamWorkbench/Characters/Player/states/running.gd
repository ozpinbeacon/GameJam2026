extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.RUNNING

func enter(_dict = {}) -> void:
	player.acceleration = player.RUN_SPEED
	player.speed = player.RUN_SPEED

func physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		finished.emit(PlayerState.JUMPING)
		
	if not Input.is_action_pressed("sprint"):
		if player.velocity.x == 0 and player.velocity.z == 0:
			finished.emit(PlayerState.IDLE)
		else:
			finished.emit(PlayerState.WALKING)
		
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player.lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	Events.player_noise.emit({"event_type": Events.NoiseType.RUN, "location": player.global_position})

#func exit() -> void:
#	# Play some animation
