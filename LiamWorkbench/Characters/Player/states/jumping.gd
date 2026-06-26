extends PlayerState


func _ready() -> void:
	super._ready()
	label = PlayerState.JUMPING

func enter(_dict = {}) -> void:
	player.velocity.y += player.JUMP_IMPULSE
	#player.acceleration = 3

func physics_process(delta: float) -> void:
	player.velocity.y -= player.gravity * delta
	
	player.direction = Input.get_axis("move_left", "move_right") * player.head.basis.x + Input.get_axis("move_forward", "move_backwards") * player.head.basis.z
	player.velocity = player.lerp_snap(player.velocity, player.direction * player.speed + player.velocity.y * Vector3.UP, player.acceleration * delta)
	
	if player.velocity.y < 0:
		finished.emit(PlayerState.FALLING)

#func exit() -> void:
#	# Play an animation
