extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.JUMPING

func enter(_dict = {}) -> void:
	player.velocity.y += player.JUMP_IMPULSE
	#player.acceleration = 3

# While vertical velocity is positive, remain in jumping state, transition to falling once velocity is negative
func physics_process(delta: float) -> void:
	player.velocity.y -= player.gravity * delta
	
	player._player_movement(delta)
	
	if player.velocity.y < 0:
		finished.emit(PlayerState.FALLING)

#func exit() -> void:
#	# Play an animation
