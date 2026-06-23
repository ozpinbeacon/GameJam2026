extends Node
class_name StateMachine


## Variables ##
var current_state: State = null
var previous_state: State = null
var stored_player_input: String

## Exported variables ##
@export var states: Array[State] = []## Drag and drop all State Nodes in this array, First in the array will be default starting state
@export var active: bool = false ## Disables the state machine when set to false
@export var player: Player## Drag and drop player root node here
@export var input_buffer: InputBuffer## Drag and drop the input buffer node if there is one
@export var debug: bool = false## Enables/Disables print messages
@export var use_debug_label: bool = false ## Enable to display current state in a label on screen when game is running
@export var debug_state_label: Label## Drag and drop debug label here if required




#region Initialisation
func _ready() -> void:
	connect_signals()
	
	# Validate player reference
	if player == null:
		printerr("STATE MACHINE: Please assign player to state machine!")
		return
	
	# Safety check to make sure some states have been added to the exported array
	if states.is_empty():
		printerr("STATE MACHINE: No states assigned in the inspector!")
		return
	
	# Wait one frame to ensure all states have loaded and ran their _ready() fucntions
	await get_tree().process_frame
	
	# Start in first state in the array
	request_new_state(states[0].state_name)
	
	# State Machine ready to go babiiiieeeeee!
	active = true
	
func connect_signals()-> void:
	SignalBus.connect_signal(self, "request_new_state")
#endregion



#region Call Process and Physics Process funcitons for current state
func _process(delta: float) -> void:
	if player.player_disabled:
		return
	
	# Run the current state update() function every frame if enabled
	if current_state and current_state.requires_updates:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if player.player_disabled:
		return
	
	# Run the current states physics update() every physics frame if enabled
	if current_state and current_state.requires_physics_updates:
		current_state.physics_update(delta)
#endregion



#region Handle player input
func _unhandled_input(event: InputEvent) -> void:
	if player.player_disabled:
		return
	
	if current_state and current_state.has_method("handle_input"):
		current_state.handle_input(event)
#endregion



#region Change State
func _on_request_new_state(new_state_name: String)-> void:## Change state via Signal
	"""
	Called via signal so that elements not connected to the player can 
	change player states if	required bu broadcasting a signal via signal bus
	"""
	request_new_state(new_state_name)

func request_new_state(new_state_name: String) -> void:## Call this function to change states
	if debug: print("STATE MACHINE: Requesting to change to new state: ", new_state_name)
	
	# Find the state by its state_name property
	var requested_state: Node = find_state(new_state_name)
	
	# Validate state exists
	if requested_state == null:
		printerr("STATE MACHINE ERROR: Could not find state: ", new_state_name)
		return
	
	# Check if already in requested state
	if requested_state == current_state:
		if debug: print("STATE MACHINE: Already in state: ", new_state_name)
		return
	
	# Exit current state
	if current_state:
		current_state.transitioning = true
		current_state.exit_state()
		current_state.state_active = false
	
	# Store previous state
	previous_state = current_state
	
	# Enter new state
	current_state = requested_state
	current_state.transitioning = false
	current_state.state_active = true
	current_state.enter_state()
	
	if debug: print("STATE MACHINE: Successfully changed to state: ", new_state_name)
	
	# Update debug label only if enabled
	if use_debug_label == false:
		return	
		
	# Safety first bitch
	if debug_state_label == null: 
		printerr(self, ": ERROR! No debug_state_label assigned to exported variable")
		return
	
	# Update the labels text
	debug_state_label.text = str(current_state)

func find_state(state_name: String) -> State:
	for state in states:
		if state.state_name == state_name:
			return state
	return null
#endregion
