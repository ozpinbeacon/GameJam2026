class_name StateMachine extends Node

@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	state.enter()

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_process(delta)

func _transition_to_next_state(next_state, payload: Dictionary = {}) -> void:
	state.exit()
	state = get_node(next_state)
	state.enter(payload)

func get_state() -> String:
	return state.label
