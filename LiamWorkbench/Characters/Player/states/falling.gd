extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.FALLING

func physics_process(delta: float) -> void:
	player.velocity.y -= player.gravity * delta
	
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player.lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	if player.is_on_floor():
		if player.velocity.x == 0 and player.velocity.z == 0:
			finished.emit(PlayerState.IDLE)
		elif Input.is_action_pressed("sprint"):
			finished.emit(PlayerState.RUNNING)
		else:
			finished.emit(PlayerState.WALKING)

#func exit() -> void:
#	# Play an animation
