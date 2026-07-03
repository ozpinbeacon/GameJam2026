class_name Player extends CharacterBody3D

# Character base stats - constants
const JUMP_IMPULSE = 5
const WALK_SPEED = 5
const RUN_SPEED = 12
const CROUCH_SPEED = 3
const AIR_SPEED = 3
var CROUCH_DIFF = .5

# Character base stats - variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var acceleration = WALK_SPEED
var speed = WALK_SPEED
var camera_sensitivity = 0.25
var camera_acceleration = 2
var crouched = false

# Character part variables
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var cursor = $Head/Camera3D/Cursor
@onready var cursor_label = $Head/Camera3D/CursorLabel
@onready var hand = $Hand

# State Machine
@onready var fsm = $StateMachine

# Animation Player
@onready var animation_player = $AnimationPlayer

# Character item variables
@onready var flashlight = $Hand/Torch

# Movement control variables
var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

# Character action variables
@export var has_flashlight: bool = false
	
# One-time events
func _unhandled_input(event):
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
		Events.player_noise.emit({"event_type": Events.NoiseType.YELL, "location": global_position})
		
	fsm.state.input(event)

# Continuous events
func _physics_process(delta):
	# If cursor is targeting an interactable item, show label
	if cursor.is_colliding() and cursor.get_collider() is InteractableObject:
		cursor_label.show()
		cursor_label.text = cursor.get_collider().label
	else:
		cursor_label.hide()

	fsm.state.physics_process(delta)

	# Lerp hand movement
	hand.rotation.y = lerp(hand.rotation.y, -deg_to_rad(head_y_axis), camera_acceleration * delta)
	hand.rotation.x = lerp(hand.rotation.x, -deg_to_rad(camera_x_axis), camera_acceleration * delta)

	# Camera movement
	head.rotation.y = -deg_to_rad(head_y_axis)
	camera.rotation.x = clampf(-deg_to_rad(camera_x_axis), -deg_to_rad(70), deg_to_rad(70))
	
	# Move and slide
	move_and_slide()

func lerp_snap(source: Vector3, destination: Vector3, weight: float) -> Vector3:
	var lerp_result = source.lerp(destination, weight)
	if lerp_result.is_zero_approx():
		return Vector3.ZERO
	else:
		return lerp_result
