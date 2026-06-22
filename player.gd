extends CharacterBody3D

# Character animation states
enum States {IDLE, WALKING, RUNNING, CROUCHING, JUMPING, FALLING, NULL}

# Base character variables
var state: States = States.IDLE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var cameraSensitivity = 0.25
var cameraAcceleration = 2
var jumpImpulse = 5
@export var playerSpeed = 5
@export var playerAcceleration = 5

# Character part variables
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var cursor = $Head/Camera3D/Cursor
@onready var cursorIndicator = $Head/Camera3D/CursorIndicator
@onready var hand = $Hand
@onready var flashlight = $Hand/SpotLight3D

# Movement control variables
var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

# Character action variables
var flashlight_bool = true
	
# One-time events
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head_y_axis += event.relative.x * cameraSensitivity
		camera_x_axis += event.relative.y * cameraSensitivity
	
	if event.is_action_pressed("flashlight_toggle"):
		if flashlight_bool:
			flashlight_bool = false
			flashlight.hide()
		else:
			flashlight_bool = true
			flashlight.show()

# Continuous events
func _physics_process(delta):
	if cursor.is_colliding():
		if cursor.get_collider().is_in_group("interactable"):
			cursorIndicator.show()
	else:
		cursorIndicator.hide()
		
	
	if Input.is_action_pressed("sprint"):
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
	elif state not in [States.JUMPING, States.FALLING, States.CROUCHING] and not Input.is_anything_pressed():
		set_state(States.IDLE)

	playerAcceleration = 8 if state == States.RUNNING else 5
	direction = Input.get_axis("move_left", "move_right") * head.basis.x + Input.get_axis("move_forward", "move_backwards") * head.basis.z
	velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)
	
	head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
	camera.rotation.x = clampf(lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta), -deg_to_rad(70), deg_to_rad(70))

	
	hand.rotation.y = -deg_to_rad(head_y_axis)
	hand.rotation.x = -deg_to_rad(camera_x_axis)
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jumpImpulse
	else:
		velocity.y -= gravity * delta

	if not is_on_floor() and velocity.y > 0:
		set_state(States.JUMPING)
	elif not is_on_floor() and velocity.y < 0:
		set_state(States.FALLING)
		
	move_and_slide()

func set_state(new_state: States) -> void:
	var prev_state := state
	state = new_state
	print("Set state to " + get_state(new_state))

func get_state(passedState: States = States.NULL) -> String:
	var state_value: States
	if passedState != States.NULL:
		state_value = passedState
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
