extends AnimationTree
class_name PlayerAnimationTree
"""
Handles animations via functions that are called from states and state machine
or via signals
"""

## Blend Nodes ##
const GRINDING_BLEND_AMOUNT: String = "parameters/GRINDING_BLEND/blend_amount"
const FALLING_BLEND_AMOUNT: String = "parameters/FALLING_BLEND/blend_amount"
const RUN_IDLE_FALL_BLEND_AMOUNT: String = "parameters/RUN_IDLE_FALL_BLEND3/blend_amount"

## One Shots ##
const SLIDE_ONE_SHOT_REQUEST: String = "parameters/SLIDE/request"
const JUMP_ONE_SHOT_REQUEST: String = "parameters/JUMP/request"
const ATTACK_IDLE_ONE_SHOT_REQUEST: String = "parameters/ATTACK_IDLE/request"
const ATTACK_RUNNING_ONE_SHOT_REQUEST: String = "parameters/ATTACK_RUNNING/request"
const LAND_ONE_SHOT_REQUEST: String = "parameters/LAND/request"

## Pass these strings as variables for this node to get the matching parameter to
## modify. Saves having to send the entrie parameter string as a variable.
const _parameter_dictionary: Dictionary = {
	"SLIDE":SLIDE_ONE_SHOT_REQUEST,
	"JUMP":JUMP_ONE_SHOT_REQUEST,
	"ATTACK_IDLE":ATTACK_IDLE_ONE_SHOT_REQUEST,
	"ATTACK_RUNNING":ATTACK_RUNNING_ONE_SHOT_REQUEST,
	"LAND":LAND_ONE_SHOT_REQUEST}

var grind_value: float = 0.0## This value is lerped towards target_grind_value every physics frame
var target_grind_value: float = 0.0## This value is set as a target for grind_value to lerp towards
var grind_blend_speed: float = 10.0## The amount by which we lerp the blend value towards the target value each physics frame

var fall_value: float = 0.0
var target_fall_value: float = 0.0
var fall_blend_speed: float = 15.0

var run_idle_fall_value: float = 0.0
var target_run_idle_fall_value: float = 0.0
var run_idle_fall_blend_speed: float = 15.0




func _physics_process(delta: float) -> void:
	_lerp_blend_values(delta)
	_upadte_blend_tree()


func _lerp_blend_values(delta: float)-> void:
	# Get the current value of the blend tree
	var current_run_idle_fall_blend_value = get(RUN_IDLE_FALL_BLEND_AMOUNT)
	var current_grind_blend_value = get(GRINDING_BLEND_AMOUNT)
	#print("current_grind_blend_value: ", current_grind_blend_value)
	#print("target_grind_value: ", target_grind_value)
	#print("--------")
	#print()
	
	# Compare the current value to the target value and lerp towards target if they dont match
	if current_run_idle_fall_blend_value != target_run_idle_fall_value:
		run_idle_fall_value = lerpf(run_idle_fall_value, target_run_idle_fall_value, run_idle_fall_blend_speed * delta)
	if current_grind_blend_value != target_grind_value:
		grind_value = lerpf(grind_value, target_grind_value, grind_blend_speed * delta)


func _upadte_blend_tree()-> void:
	set(RUN_IDLE_FALL_BLEND_AMOUNT, run_idle_fall_value)
	set(GRINDING_BLEND_AMOUNT, grind_value)


func fire_one_shot(one_shot_animation_name: String)-> void:
	# Get the parameter path based on the parameter given
	var param_path = _parameter_dictionary[one_shot_animation_name]
	# Use the path to request the one shot fires
	self.set(param_path, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)



func abort_one_shot(one_shot_animation_name: String)-> void:##Stops the one shot animation from playing
	# Get the parameter path based on the parameter given
	var param_path = _parameter_dictionary[one_shot_animation_name]
	# Use the path to request the one shot fires
	self.set(param_path, AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func fade_out_one_shot(one_shot_animation_name: String)-> void:##Same as abort one shot except the animation fades out smoothly instead of abruptly stopping
	# Get the parameter path based on the parameter given
	var param_path = _parameter_dictionary[one_shot_animation_name]
	# Use the path to request the one shot fires
	self.set(param_path, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func update_target_blend_value(value: float = 0.0, blend_target_name: String = "" )-> void:##Sets the target to value to lerp towards
	if blend_target_name == "":
		target_run_idle_fall_value = value
		return
	if blend_target_name == "GRINDING":
		print("setting grind target belnd value now to: ", value)	
		target_grind_value = value
		print("updated target_grind_value: ", target_grind_value)

		



func update_blend_value(blend_target_name: String, value: float)-> void:##Updates the blend value immediately(NO LERPING VALUES)
	match blend_target_name:
		"GRINDNING":
			grind_value = value
			target_grind_value = value
			set(GRINDING_BLEND_AMOUNT, value)
