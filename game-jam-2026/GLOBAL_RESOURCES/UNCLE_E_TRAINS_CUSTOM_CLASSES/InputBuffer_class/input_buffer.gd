extends Node
class_name InputBuffer
"""
Stores inputs for a brief time to be checked by state machine when
transitioning to other states, allows players to press a button
slightly early and still have it count like they pressed it at 
the right time
NOTE!!!! Make sure state machine root node has a variable to store
the buffered input in! var stored_player_input: String
"""

# Variables
var stored_player_input: String = "" ##For Input buffer component

# Exported Variables
@export var state_machine: StateMachine## The state machine node that controls everything, typically the parent of this node and all the individual states
@export_group("Buffered Inputs")
@export var buffered_inputs: Dictionary = {}## Key: String == Name of the input action to check for. value: String == Name of the associated State to transition to if this input gets accepted
@export_group("Timer Settings")
@export var input_timer_buffer: Timer
@export var buffer_time: float = 0.5## How long to store the input before deleting it. Tweak to store early inputs for longer
@export_group("DEBUG")
@export var use_debug_label: bool = false
@export var debug_label: Label##Optional debug label for displaying the currently stored input


#region Initialisation
func _ready() -> void:
	# Set the input buffers timer
	input_timer_buffer.set("wait_time" , buffer_time)
	
	# Connect the timers timeout signal and set one shot to true
	input_timer_buffer.timeout.connect(_on_input_timer_buffer_timeout)
	input_timer_buffer.one_shot = true
	
	# Wait a frame i cant remember why... i think it fixed a timing issue
	await get_tree().process_frame
#endregion


#region Recieved input
func _unhandled_input(event: InputEvent) -> void:
	# This node only works if the current state requires input buffering
	if not state_machine or not state_machine.current_state or not state_machine.current_state.requires_input_buffer:
		return
		
	# For every unhandled input, check if its one of the inputs that need to be buffered
	check_if_event_needs_buffer(event)
#endregion


#region Start input buffer and update debug label
func check_if_event_needs_buffer(event: InputEvent)-> void:
	for action in buffered_inputs.keys():
		
		# Check if the input event is one of the actions to be input buffered
		if event.is_action_pressed(action):
			
			# Get the value of the state from the bufered inputs dict
			stored_player_input = buffered_inputs[action]
			
			# Start the timer to delete the stored input on timeout
			input_timer_buffer.start(buffer_time)
			
			# Return early if debug label doesnt need to be updated
			if not use_debug_label:
				return
			
			# Safety first bitch
			if debug_label == null: 
				printerr(self, ": ERROR! No debug label assigned to exported variable")
				return
			
			# Update the text
			debug_label.text = state_machine.stored_player_input


func _on_input_timer_buffer_timeout()-> void:
	# Buffer timer finished. Clear the stored input.
	stored_player_input = ""
	
	# Check if debug label wants to be updadted
	if not use_debug_label:
		return
		
	# Safety first bitch
	if debug_label == null: 
		printerr(self, ": ERROR! No debug label assigned to exported variable")
		return
	
	# Update the text in the label
	debug_label.text = "InputBuffer Stored Input: " + stored_player_input


func clear_buffered_input()-> void:
	stored_player_input = ""		
#endregion
