extends AnimationTree
class_name MonsterAnimationTree


#Set the one shots to be activated via a function
#make the idle and run animaations
#make a RNG for playing random glitch animations


"""
Animation Trees root node is a state machine root node.
Only one node inside the state machine can be active at a time.
Clicking the pencil icon on a child node (such as a blend tree node) will open it up so it can be edited
The output node inside a child node is the animation of pose that will play when the parent state machine travels to this node
Blend2 nodes and Blend3 Nodes will smoothly blend between animations by passing a value to the spceific blend nodes paramater e.g blend3node:value = 1.0
"""

const MOVEMENT_BLEND3_NODE_PARAM_PATH: String = "parameters/Movement/IdleWalkRun/blend_amount"
const SCREAM_ONE_SHOT_REQUEST_PARAM_PATH: String = "parameters/Movement/ScreamOneShot/request"
const SCREAM_WHILE_MOVING_ONE_SHOT_REQUEST_PARAM_PATH: String = "parameters/Movement/ScreamWhileMovingOneShot/request"

var target_movement_blend_value: float = -1.0## idle = -1.0, walk = 0.0, run = 1.0
var current_movement_blend_value: float = -1.0



func _ready() -> void:
	get_tree().create_timer(4.0).timeout.connect(test_scream)

func test_scream()-> void:
	var one_shot_request = get(SCREAM_ONE_SHOT_REQUEST_PARAM_PATH)
	

#func test_update_blend_value()-> void:
	#var test_value: float = randf_range(-1.0,1.0)
	#test_value = snappedf(test_value, 0.1)
	#print("UPDATING BLEND VALUE NOW TO: ", test_value)
	#set_movement_blend_target(test_value)
	#get_tree().create_timer(5.0).timeout.connect(test_update_blend_value)

func _process(delta: float) -> void:
	if movement_blend_target_matches_current_value() == false:
		update_current_movement_blend_value(delta)





#region Movement Blend Tree amount
func set_movement_blend_target(target_value: float = 0.0)-> void:
	"""
	Set the target value to lerp towards, blending the movement animation between
	idle(target_value = -1.0)
	walk(target_value = 0.0)
	rund(target_value = 1.0)
	"""
	# Make sure the target value is between -1.0 and 1.0 and only has one decimal place
	target_value = clampf(target_value, -1.0, 1.0)
	target_value = snappedf(target_value, 0.1)
	
	# Update the value stored in the variable
	target_movement_blend_value = target_value

func movement_blend_target_matches_current_value()-> bool:
	if current_movement_blend_value == target_movement_blend_value:
		return true
	return false

func update_current_movement_blend_value(delta: float)-> void:
	#Lerp towards new value for the blend target value
	current_movement_blend_value = lerpf(current_movement_blend_value, target_movement_blend_value, delta)
	set(MOVEMENT_BLEND3_NODE_PARAM_PATH, current_movement_blend_value)
#endregion
	
