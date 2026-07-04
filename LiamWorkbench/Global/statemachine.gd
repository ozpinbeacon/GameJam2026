class_name StateMachine extends Node

# Initial state
@export var initial_state: State = null

# If initial state is not set in the GUI, set to the first child of the object
@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

# Connect to the finished signal of all children
func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	state.enter()

# State process
func _process(delta: float) -> void:
	state.update(delta)

# State physics process
func _physics_process(delta: float) -> void:
	state.physics_process(delta)

# To be executed when transitioning states
func _transition_to_next_state(next_state, payload: Dictionary = {}) -> void:
	state.exit()
	state = get_node(next_state)
	state.enter(payload)

# Helper function for current state label
func get_state() -> String:
	return state.label
