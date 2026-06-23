extends Node
## Camera Transition Helper (Global)

# Constants #
const YELLOW: String = "yellow"
const GREEN: String  = "green"  ## Success
const RED: String    = "red"    ## Failures / Errors
const LERP_SPEED: float = 18
const LERP_FINISH_THRESHOLD: float = 0.25

# Child Node References #
@onready var camera_3d: Camera3D = $Camera3D

# Variables #
var active_camera: Camera3D
var transitioning: bool = false
var lerping_camera: bool = false
var lerp_target_camera: Camera3D

@export var debug: bool = true

signal finished_transitioning



# Debug Function #
func _debug(message: String, colour: String = YELLOW) -> void:
	if not debug:
		return
	var color_tag_open = "[color=" + colour + "]"
	var color_tag_close = "[/color]"
	print_rich(color_tag_open + "CAMERA TRANSITION: " + message + color_tag_close)



func move_current_camera_to_match_target_transform(target: Node, duration: float = 0.1)-> void:##
	# Make sure active camera variable has the currently active camera stored
	if GameManager.current_camera == null or not is_instance_valid(GameManager.current_camera):
		printerr(name, ": No current camera set in GM")
		return
	active_camera = GameManager.current_camera

	# Tween the active camera to match the targets Transform
	var tween = get_tree().create_tween()
	print(name, ": active camera: ",active_camera)
	tween.tween_property(active_camera, "global_transform", target.global_transform, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)

	# Makes the function async so it can be awaited
	await tween.finished


func move_camera_A_to_match_target_transform(camera_a: Camera3D, target: Node, duration: float = 0.1)-> void:##
	# Tween camera A's transform to match the Camera B's Transform
	var tween = get_tree().create_tween()
	print(name, ": Tweening transform of camera_a: ",camera_a)
	print(name, ": to match transform of target: ",target)
	tween.tween_property(camera_a, "global_transform", target.global_transform, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)

	# Makes the function async so it can be awaited
	await tween.finished



# Basic Camera Switching #
func switch_camera(from: Camera3D, to: Camera3D) -> void:
	_debug("Switching camera from " + str(from.name) + " to " + str(to.name), YELLOW)
	from.current = false
	to.current = true
	_debug("Camera switched successfully", GREEN)


# 3D Camera Transition #
func transition_camera_3d(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	print()
	_debug("transition_camera_3d() called", YELLOW)
	if transitioning:
		_debug("Transition already in progress — aborting new transition", RED)
		return
	
	
	_debug("From: " + str(from.name), YELLOW) 
	_debug("To: " + str(to.name), YELLOW)
	_debug("Duration: " + str(duration), YELLOW)
	print()
	
	# Copy parameters of the first camera
	camera_3d.fov = from.fov
	camera_3d.cull_mask = from.cull_mask
	
	# Move our transition camera to the first camera position
	camera_3d.global_transform = from.global_transform
	
	# Make our transition camera current
	camera_3d.current = true
	transitioning = true
	
	# Move to the second camera, adjusting parameters
	var tween = get_tree().create_tween()
	tween.tween_property(camera_3d, "global_transform", to.global_transform, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(camera_3d, "fov", to.fov, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	# Make the second camera current
	to.current = true
	transitioning = false
	finished_transitioning.emit()

	_debug("Transition to camera '" + str(to.name) + "' complete", GREEN)



# 3D camera transition using lerp instead of tween (see process())
func start_lerping_towards_target_camera(from: Camera3D, to: Camera3D) -> void:
	_debug("transition_camera_3d() called", YELLOW)
	if transitioning:
		_debug("Transition already in progress — aborting new transition", RED)
		return
	
	_debug("From: " + str(from.name), YELLOW) 
	_debug("To: " + str(to.name), YELLOW)
	
	# Copy parameters of the first camera onto transition camera
	camera_3d.fov = from.fov
	camera_3d.cull_mask = from.cull_mask
	camera_3d.global_transform = from.global_transform
	
	# Set the target for the transition camera to lerp towards
	lerp_target_camera = to
	
	# Make our transition camera current
	camera_3d.current = true
	transitioning = true

	# Start the lerp by setting the bool to true
	lerping_camera = true
	


func _process(delta: float) -> void:
	if not lerping_camera:
		return
	lerp_transition_camera(delta)



func lerp_transition_camera(delta: float)-> void:
	var lerped_value: Transform3D = lerp(camera_3d.global_transform, lerp_target_camera.global_transform, delta * LERP_SPEED)
	
	# Check if origin distance and basis similarity are close enough
	var close_enough: bool = camera_3d.global_transform.origin.distance_to(lerp_target_camera.global_transform.origin) < LERP_FINISH_THRESHOLD
	
	# If close enough then the lerp is complete
	if close_enough:
		#stop _process() from lerping
		lerping_camera = false
		# snap the camera to the target_pos
		camera_3d.global_transform = lerp_target_camera.global_transform
		#complete the lerp
		lerp_complete_set_target_cam_as_current()
		return

	camera_3d.global_transform = lerped_value



func lerp_complete_set_target_cam_as_current()-> void:
	# Make the second camera current
	if not lerp_target_camera or not is_instance_valid(lerp_target_camera):
		printerr(name, ": lerp_target_camera is either not valid or null")
		return
	
	# Make the target camera current
	camera_3d.current = false
	lerp_target_camera.current = true
	transitioning = false
	finished_transitioning.emit()
	
	_debug("Transition to camera '" + str(lerp_target_camera.name) + "' complete", GREEN)











# 3D Path-Based Transition #
func transition_path_3d(from: Camera3D, to: Path3D, duration: float = 1.0) -> void:
	if transitioning:
		_debug("Transition already in progress — aborting new transition", RED)
		return
	
	_debug("Starting path-based camera transition to " + str(to.name), YELLOW)
	
	# Copy parameters of the first camera
	camera_3d.fov = from.fov
	camera_3d.cull_mask = from.cull_mask
	
	# Move our transition camera to the first camera position
	camera_3d.global_transform = from.global_transform
	
	# Make our transition camera current
	camera_3d.current = true
	transitioning = true
	
	# Move to the second camera, adjusting parameters
	var tween = get_tree().create_tween()
	tween.tween_property(camera_3d, "global_transform", to.global_transform, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(camera_3d, "fov", to.camera_3d.fov, duration)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	# Make the second camera current
	to.camera_3d.current = true
	to.start_path_follow()
	transitioning = false
	finished_transitioning.emit()
	_debug("Path transition to '" + str(to.name) + "' complete", GREEN)
