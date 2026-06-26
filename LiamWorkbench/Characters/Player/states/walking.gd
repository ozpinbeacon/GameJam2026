extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.WALKING

func enter(_dict = {}) -> void:
	player.acceleration = player.WALK_SPEED
	player.speed = player.WALK_SPEED

func input(event) -> void:
	if event.is_action_pressed("crouch"):
		get_viewport().set_input_as_handled()
		finished.emit(PlayerState.CROUCHING)

func physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		finished.emit(PlayerState.JUMPING)
	elif Input.is_action_pressed("sprint"):
		finished.emit(PlayerState.RUNNING)
	
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player.lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	if player.velocity.x == 0 and player.velocity.z == 0:
		finished.emit(PlayerState.IDLE)
	else:
		Events.player_noise.emit({"event_type": Events.NoiseType.WALK, "location": player.global_position})

#func exit() -> void:
#	# Play an animation
