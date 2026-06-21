extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var air_resistance = 1
@export var playerSpeed = 5
@export var playerAcceleration = 5
@export var cameraSensitivity = 0.25
@export var cameraAcceleration = 2
@export var jump_speed = 5
var mouse_sensitivity = 0.002

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hand = $Hand
@onready var flashlight = $Hand/SpotLight3D

var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head_y_axis += event.relative.x * cameraSensitivity
		camera_x_axis += event.relative.y * cameraSensitivity
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	direction = Input.get_axis("move_left", "move_right") * head.basis.x + Input.get_axis("move_forward", "move_backwards") * head.basis.z
	velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)
	
	head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
	camera.rotation.x = lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta)
	
	hand.rotation.y = -deg_to_rad(head_y_axis)
	hand.rotation.x = -deg_to_rad(camera_x_axis)
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_speed
	else:
		velocity.y -= gravity * delta
		
	move_and_slide()
