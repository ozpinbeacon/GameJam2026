extends RayCast3D
class_name InteractableObjectsRaycast

#VARIABLES#
@export var player: CharacterBody3D
@export var frames_per_check: int = 10##How many frames should pass before checking the ray cast for collisions

var currently_highlighted_interactable_component: Node = null
var frame_counter:int = 0##Counts each frame so we dont have to check for detections every frame



func _ready() -> void:
	if player == null:
		player = get_parent().get_parent()
	if player == null:
		printerr("RAYCAST: ERROR! COULDNT GET PLAYER REFERENCE?!")



func _process(_delta: float) -> void:
	## Dont run while player is disabled
	if player.player_disabled:
		return
	
	# Update the frame counter and check for collisions if counter has reached the value set int frames_per_check
	frame_counter += 1
	if frame_counter % frames_per_check == 0:  
		detect_objects()



func detect_objects():
	if not is_colliding():
		clear_detected_object_variables()
		return

	var collider: Object = get_collider()
	if collider == currently_highlighted_interactable_component:
		return

	# Clear previous
	if is_instance_valid(currently_highlighted_interactable_component):
		currently_highlighted_interactable_component.remove_highlight()

	# Check if what we hit is an InteractableComponent
	if collider is not InteractableComponent:
		currently_highlighted_interactable_component = null
		player.detected_interactable_component = null
		return

	# Highlight it
	collider.highlight_object()
	currently_highlighted_interactable_component = collider
	player.detected_interactable_component = collider


func clear_detected_object_variables():## Removes highlight on objects once a new object has been detected
	player.detected_interactable_component = null
	if currently_highlighted_interactable_component and is_instance_valid(currently_highlighted_interactable_component):
		currently_highlighted_interactable_component.remove_highlight()
		currently_highlighted_interactable_component = null
