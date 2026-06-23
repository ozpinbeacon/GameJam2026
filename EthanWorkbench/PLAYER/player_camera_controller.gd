extends Node

@export_group("Nodes")
@export var character: Player## Drag and drop the Player Node this script controls (most likely the root node of the player scene)
@export var head: Node3D ## Drag and drop the Node3D for the players head here (This will be the node that rotates when aiming and holds the players camera)

@export_subgroup("Mouse Settings")
@export_range(1, 100, 1) var mouse_sensitivity: int = 50

@export_group("Settings")
@export_subgroup("Clamp Settings")
@export var max_pitch: float = 89##In degrees
@export var min_pitch: float = -69##In degrees


#region Ethans Explanations and stuff (click the arrow to the left to show/hide)
## set_use_accumulated_input ##
"""
I read an article from some code guru on the internet, he reccomneds 
setting set_use_accumulated_input to false in every character/camera 
controller to avoid frame rate drops from merging similar inputs together and
processing them all at the end of every physics frame or something. Cant 
rememeber the exact explanation
"""
#endregion


# Initialistion #
func _ready() -> void:
	# Turn off accumulate inputs and make the mouse locked to the game window
	Input.set_use_accumulated_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Handle Input from mouse and keyboard
func _input(event: InputEvent) -> void:
	# Ignore next line if mouse already captured by game window
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		
		# Capture mouse if event is left mouse click (button_index == 1 is left click)
		if event is InputEventMouseButton and event.button_index == 1: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	#Return control to computers OS when escape is pressed
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	# Mouse is being moved, handle aiming/looking
	if event is InputEventMouseMotion:
		aim_look(event)


# Camera control using mouse movements recieved from _input()
func aim_look(event: InputEventMouseMotion):
	var viewport_transform: Transform2D = get_tree().root.get_final_transform()
	var motion: Vector2 = event.xformed_by(viewport_transform).relative
	var degrees_per_unit: float = 0.001
	motion *= mouse_sensitivity
	motion *= degrees_per_unit #VALUE IS VERY SAMLL AND NEEDS TO BE MULTIPLIED BY THIS TO BE USABLE WITH GODOT
	add_yaw(motion.x)
	add_pitch(motion.y)
	clamp_pitch()

#Rotate the characters body around the local y axis
func add_yaw(amount):
	if is_zero_approx(amount):
		return
	character.rotate_object_local(Vector3.DOWN, deg_to_rad(amount))
	character.orthonormalize()

#Rotate the characters head around the local x axis
func add_pitch(amount):
	if is_zero_approx(amount):
		return
	head.rotate_object_local(Vector3.LEFT, deg_to_rad(amount))
	head.orthonormalize()

#Stops the player from rotating the head too far
func clamp_pitch():
	#RETURN FROM FUNCTION IF ROTATION IS WITHIN MIN AND MAX BOUNDS
	if head.rotation.x > deg_to_rad(min_pitch) and head.rotation.x < deg_to_rad(max_pitch):
		return
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	head.orthonormalize()
