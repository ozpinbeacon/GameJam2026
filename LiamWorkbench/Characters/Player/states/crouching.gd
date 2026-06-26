extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.CROUCHING

func enter(_dict = {}) -> void:
	player.acceleration = player.CROUCH_SPEED
	player.speed = player.CROUCH_SPEED
	player.crouched = true
	player.head.position.y -= player.CROUCH_DIFF

func input(event) -> void:
	if event.is_action_pressed("crouch"):
		get_viewport().set_input_as_handled()
		if player.velocity.x == 0 and player.velocity.z == 0:
			finished.emit(PlayerState.IDLE)
		else:
			finished.emit(PlayerState.WALKING)

func physics_process(delta: float) -> void:
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player.lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	if not (player.velocity.x == 0 and player.velocity.z == 0):
		Events.player_noise.emit({"event_type": Events.NoiseType.CROUCH_WALK, "location": player.global_position})

func exit() -> void:
	# Play an animation
	player.crouched = false
	player.head.position.y += player.CROUCH_DIFF
