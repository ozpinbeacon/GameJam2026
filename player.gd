class_name Player extends CharacterBody3D

# Character animation states
enum States {IDLE, WALKING, RUNNING, CROUCHING, JUMPING, FALLING, NULL}

# Base character variables
var state: States = States.IDLE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_sensitivity = 0.25
var camera_acceleration = 2
var jump_impulse = 5
@export var player_speed = 5
@export var player_acceleration = 5

# Character part variables
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var cursor = $Head/Camera3D/Cursor
@onready var cursor_label = $Head/Camera3D/CursorLabel
@onready var hand = $Hand

# Character item variables
@onready var flashlight = get_node("Hand/Torch")

# Movement control variables
var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

# Character action variables
var has_flashlight = false
	
# One-time events
func _input(event):
	# Base mouse movements
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head_y_axis += event.relative.x * camera_sensitivity
		camera_x_axis += event.relative.y * camera_sensitivity
	
	# Toggle flashlight if flashlight is acquired
	if event.is_action_pressed("flashlight_toggle") and has_flashlight:
		flashlight.toggle_torch()
	
	# If cursor is targeting an interactable item, click to execute interaction
	if event.is_action_pressed("click") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if cursor.is_colliding() and cursor.get_collider() is InteractableObject:
			cursor.get_collider().interact()
	
	if event.is_action_pressed("yell"):
		Events.player_noise.emit(Events.NoiseType.YELL)

# Continuous events
func _physics_process(delta):
	# If cursor is targeting an interactable item, show label
	if cursor.is_colliding() and cursor.get_collider() is InteractableObject:
		cursor_label.show()
		cursor_label.text = cursor.get_collider().label
	else:
		cursor_label.hide()
		
	# State switch
	if not is_on_floor() and velocity.y > 0:
		set_state(States.JUMPING)
	elif not is_on_floor() and velocity.y < 0:
		set_state(States.FALLING)
	elif Input.is_action_pressed("sprint"):
		set_state(States.RUNNING)
	elif Input.is_action_just_pressed("crouch"):
		if state != States.CROUCHING:
			head.position.y = .5
			set_state(States.CROUCHING)
		if state == States.CROUCHING:
			head.position.y = 1.6
			set_state(States.IDLE)
	elif Input.is_anything_pressed() and not Input.is_action_pressed("ui_cancel"):
		set_state(States.WALKING)
	elif state not in [States.CROUCHING] and not Input.is_anything_pressed():
		set_state(States.IDLE)

	# Set player velocity based on inputs and character state
	player_acceleration = 8 if state == States.RUNNING else 5
	direction = Input.get_axis("move_left", "move_right") * head.basis.x + Input.get_axis("move_forward", "move_backwards") * head.basis.z
	velocity = velocity.lerp(direction * player_speed + velocity.y * Vector3.UP, player_acceleration * delta)
	
	if velocity.x != 0 or velocity.z != 0:
		if state == States.RUNNING:
			Events.player_noise.emit(Events.NoiseType.RUN)
		elif state == States.WALKING:
			Events.player_noise.emit(Events.NoiseType.WALK)

	# Lerp camera movement
	head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), camera_acceleration * delta)
	camera.rotation.x = clampf(lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), camera_acceleration * delta), -deg_to_rad(70), deg_to_rad(70))

	# Instant hand movement
	hand.rotation.y = -deg_to_rad(head_y_axis)
	hand.rotation.x = -deg_to_rad(camera_x_axis)
	
	# Jump and fall velocity
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_impulse
	else:
		velocity.y -= gravity * delta
	
	# Move and slide
	move_and_slide()

func set_state(new_state: States) -> void:
	state = new_state
	print("Set state to " + get_state(new_state))

func get_state(passed_state: States = States.NULL) -> String:
	var state_value: States
	if passed_state != States.NULL:
		state_value = passed_state
	else:
		state_value = state
	
	match state_value:
		States.IDLE:
			return "Idle"
		States.WALKING:
			return "Walking"
		States.RUNNING:
			return "Running"
		States.CROUCHING:
			return "Crouching"
		States.JUMPING:
			return "Jumping"
		States.FALLING:
			return "Falling"
		_:
			return "Unknown"
