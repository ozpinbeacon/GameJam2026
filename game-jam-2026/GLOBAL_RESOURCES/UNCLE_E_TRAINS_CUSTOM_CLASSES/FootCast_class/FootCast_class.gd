extends Area3D
class_name FootCast

## Variables ##
var footcast_cooling_down: bool = false
var frame_counter:int = 0 ## Counts how many frames have passed


## Exported Variables ##
@export_enum("Upper", "Lower")var footcast_type: String = "Upper"
@export var collision_mask_layers_to_monitor_for: Array[int] = [1]## Add all layers that any environment or other collidible object exists on that this footcast should monitor for

@export var frames_per_check: int = 10## How many frames should pass between checking footcasts
@export var footcast_cooldown_timer_amount: float = 1.0##How long in Seconds until footcast can be used again

@export var player: Player
@export var upper_footcast: FootCast
@export var lower_footcast: FootCast



#region Initialisation
func _ready() -> void:
	# Make sure player is valid
	if player == null or is_instance_valid(player) == false:
		printerr(name, ": ERROR! Somethings wrong with player reference. Double check exported variable")
	
	# Set the collision masks
	setup_collision_masks()

func setup_collision_masks()-> void:
	#Reset any default values assigned to collision mask
	set("collision_mask", 0)##Uses binary value to set the flags
	
	# Footcasts need to monitor but dont need to be monitored
	set("monitorable", false)
	set("monitoring", true)
	
	# Safety check
	if collision_mask_layers_to_monitor_for.is_empty():
		printerr(name, ": ERROR! No collision mask layers set in exported array. Please add some layers to enable footcast to detect objects")
		return
	
	# Loop through the array and set requested mask layers to true
	for collision_mask_layer in collision_mask_layers_to_monitor_for:
		set_collision_mask_value(collision_mask_layer, true)
#endregion


func _process(_delta: float) -> void:## Runs every frame
	#Only monitor for collisions if this is the LOWER footcast
	if footcast_type == "UPPER":
		return
	
	# Increase frame counter, return early if not enough frames have passed since last check
	frame_counter += 1
	if frame_counter < frames_per_check:
		return
	
	# Reset the frame counter and Check for collisions
	frame_counter = 0
	check_foot_casts()


#region Check For Collisions
func check_foot_casts() -> void:
	# Prevents jittering from multiple retriggers from the same ledge
	if footcast_cooling_down:
		return
	
	# If no collisions then return
	if get_overlapping_bodies().is_empty():
		return
	
	# If upper footcast is not colliding, move player up over small ledge
	if upper_footcast.get_overlapping_bodies().is_empty():
		player.global_position.y += upper_footcast.position.y
		
		# Set cooldown to true and start the cooldown timer to reset it back to false
		footcast_cooling_down = true
		get_tree().create_timer(footcast_cooldown_timer_amount).timeout.connect(_on_footcast_cooldown)

func _on_footcast_cooldown() -> void:
	footcast_cooling_down = false
		
#endregion
