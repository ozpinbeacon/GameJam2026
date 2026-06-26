extends PlayerState

func _ready() -> void:
	super._ready()
	label = PlayerState.IDLE

func enter(_dict = {}) -> void:
	# play some animation
	print("Player entered idle state")
	player.velocity = Vector3.ZERO
	
func input(event) -> void:
	if event.is_action_pressed("crouch"):
		get_viewport().set_input_as_handled()
		finished.emit(PlayerState.CROUCHING)

func physics_process(_delta: float) -> void:
	if Input.is_action_pressed("jump"):
		finished.emit(PlayerState.JUMPING)
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backwards"):
		if Input.is_action_pressed("sprint"):
			finished.emit(PlayerState.RUNNING)
		else:
			finished.emit(PlayerState.WALKING)

func exit() -> void:
	print("Player exited idle state")
