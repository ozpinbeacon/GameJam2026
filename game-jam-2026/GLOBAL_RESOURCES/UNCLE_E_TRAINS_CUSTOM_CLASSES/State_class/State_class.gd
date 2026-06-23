@abstract
extends Node
class_name State

@export var state_name: String = ""
@export var requires_updates: bool = false
@export var requires_physics_updates: bool = false
@export var requires_input_buffer: bool = false##Enables input buffering for this state
@export var animation_tree: AnimationTree

var player: Player # Reference to player (automatically gets it from State Machine parent node)
var state_active: bool = false
var state_machine: StateMachine  # Reference back to state machine
var transitioning: bool = false##Stops state from checking for transitions while already transitioning. this allows physics update to still run without worrying about doubling up on transition calls to other states

signal exit_signal

func _ready() -> void:
	state_machine = get_parent()  # Gets the StateMachine node
	player = state_machine.player
	
@abstract func enter_state() -> void

@abstract func exit_state() -> void

## Optional override methods ##
func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
