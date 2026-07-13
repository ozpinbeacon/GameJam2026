extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.FALLING

# Allow the player to move in mid-air and go to appropriate state once on the ground
func physics_process(delta: float) -> void:
	player.velocity.y -= player.gravity * delta
	
	player._player_movement(delta)
	
	if player.is_on_floor():
		if player.velocity.x == 0 and player.velocity.z == 0:
			finished.emit(PlayerState.IDLE)
		elif Input.is_action_pressed("sprint"):
			finished.emit(PlayerState.RUNNING)
		else:
			finished.emit(PlayerState.WALKING)

#func exit() -> void:
#	# Play an animation
