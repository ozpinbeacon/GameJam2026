class_name Player extends CharacterBody3D

# UI signals
signal cursor_label_update

# Control constants
var CAMERA_CONTROLLER_ROTATION_SPEED = Settings.player.CAMERA_CONTROLLER_ROTATION_SPEED
var CAMERA_MOUSE_SENSITIVITY = Settings.player.CAMERA_MOUSE_SENSITIVITY
var CAMERA_ACCELERATION = Settings.player.CAMERA_ACCELERATION

# Variable for control method
var MOUSE_KEYBOARD_CONTROLS = Settings.player.MOUSE_KEYBOARD_CONTROLS

# Character base stats - constants
const JUMP_IMPULSE = 5
const WALK_SPEED = 5
const RUN_SPEED = 12
const RUN_ACCEL = 1.1
const CROUCH_SPEED = 3
const AIR_SPEED = 3
var CROUCH_DIFF = .5
const BASE_STAMINA = 100

# Character base stats - variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var acceleration = WALK_SPEED
var speed = WALK_SPEED
var crouched = false

# Character stamina system
const STAMINA_REGEN = 10
const MAX_STAMINA = 100
var stamina = BASE_STAMINA
var stamina_depleted = false
var stamina_inf = false

# Speed multiplier for pills
var p_speed_on = false
const P_SPEED = 1.2

# Character part variables
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var cursor = $Head/Camera3D/Cursor
@onready var hand = $Hand

# State Machine
@onready var fsm = $StateMachine

# Animation Player
@onready var animation_player = $AnimationPlayer

# Character item variables
@onready var lantern = $Hand/Lantern

# Character inventory
@onready var inventory = $Inventory

# Movement control variables
var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

# Export debug variable to editor for testing
@export var debug = false

func _ready() -> void:
	# Connect to inventory signal for new items
	inventory.item_received.connect(_item_received)
	# If debug, give all items for testing
	if self.debug:
		self.inventory.consumables.pills = 99
		self.inventory.consumables.holy_water = 99
		self.inventory.key_items.lantern = true
		self.lantern.show()

func _process(delta):
	# Regenerate stamina
	if self.stamina < MAX_STAMINA:
		# Regenerate stamina at a slower rate if it was completed depleted
		if self.stamina_depleted:
			self.stamina += STAMINA_REGEN/1.2 * delta
		else:
			self.stamina += STAMINA_REGEN * delta
		
		# Set to whole integer to remove any floating decimals and set depleted to false
		if self.stamina >= 100:
			self.stamina = 100
			self.stamina_depleted = false
	
	# Gamepad camera movement if gamepad is active input method
	if not MOUSE_KEYBOARD_CONTROLS:
		head_y_axis += (Input.get_action_strength("view_right") - Input.get_action_strength("view_left")) * CAMERA_CONTROLLER_ROTATION_SPEED
		camera_x_axis += (Input.get_action_strength("view_down") - Input.get_action_strength("view_up")) * CAMERA_CONTROLLER_ROTATION_SPEED

# One-time events
func _unhandled_input(event):
	# Debug switch input methods, would likely prefer to implement in a menu rather than this
	if event.is_action_pressed("switch_controls"):
		if MOUSE_KEYBOARD_CONTROLS:
			MOUSE_KEYBOARD_CONTROLS = false
		else:
			MOUSE_KEYBOARD_CONTROLS = true
	
	# Base mouse movements
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and MOUSE_KEYBOARD_CONTROLS:
		head_y_axis += event.relative.x * CAMERA_MOUSE_SENSITIVITY
		camera_x_axis += event.relative.y * CAMERA_MOUSE_SENSITIVITY
	
	# Toggle flashlight if flashlight is acquired
	if event.is_action_pressed("flashlight_toggle") and inventory.key_items.lantern:
		lantern.toggle_lantern()
	
	# If cursor is targeting an interactable item, click to execute interaction
	if event.is_action_pressed("click") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if cursor.is_colliding() and cursor.get_collider() is InteractableObject:
			cursor.get_collider().interaction()
	
	# Debug tool to get enemy attention, maybe could implement into actual mechanic
	if event.is_action_pressed("yell"):
		Events.player_noise.emit({"event_type": Events.NoiseType.YELL, "location": global_position})
	
	# If any pills are in inventory, run function
	if event.is_action_pressed("consumable_pills"):
		if inventory.consumables.pills > 0:
			_use_pills()
	
	# Turn off stamina while testing
	if event.is_action_pressed("debug_stamina"):
		if stamina_inf:
			self.stamina_inf = false
		else:
			self.stamina_inf = true
	
	# Current state input events
	fsm.state.input(event)

# Continuous events
func _physics_process(delta):
	# If cursor is targeting an interactable item, show label
	if cursor.is_colliding() and cursor.get_collider() is InteractableObject:
		self.cursor_label_update.emit(cursor.get_collider().ui_label)
	else:
		self.cursor_label_update.emit()
	
	# Current state physics process
	fsm.state.physics_process(delta)

	# Lerp hand movement
	hand.rotation.y = lerp(hand.rotation.y, -deg_to_rad(head_y_axis), CAMERA_ACCELERATION * delta)
	hand.rotation.x = lerp(hand.rotation.x, -deg_to_rad(camera_x_axis), CAMERA_ACCELERATION * delta)

	# Camera movement
	head.rotation.y = -deg_to_rad(head_y_axis)
	camera.rotation.x = clampf(-deg_to_rad(camera_x_axis), -deg_to_rad(70), deg_to_rad(70))
	
	# Move and slide
	move_and_slide()

func _item_received(sender) -> void:
	# What to do with different items received, likely only used for Key items
	match sender:
		PlayerItem.ITEM_TYPES.Lantern:
			lantern.show()

# When pills are used
func _use_pills() -> void:
	# Remove one pill from inventory
	self.inventory.consumables.pills -= 1
	
	# Set infinite stamina, speed multiplier and remove depletion debuff if active
	self.stamina_inf = true
	self.p_speed_on = true
	if self.stamina_depleted:
		self.stamina_depleted = false
	
	# Change camera settings to show pill effect
	self.animation_player.play("START_PILLS")
	
	# Wait for 10 seconds to have pill effect
	await get_tree().create_timer(10).timeout
	
	# Turn off infinite stamina and speed multiplier
	self.stamina_inf = false
	self.p_speed_on = false
	
	# Return camera to normal
	self.animation_player.play("END_PILLS")

# Helper function to avoid lerp slowing to approach zero
func _lerp_snap(source: Vector3, destination: Vector3, weight: float) -> Vector3:
	var lerp_result = source.lerp(destination, weight)
	if lerp_result.is_zero_approx():
		return Vector3.ZERO
	else:
		return lerp_result
