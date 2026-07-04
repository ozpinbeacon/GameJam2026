class_name State extends Node

# Signal for when current state is finished and what the next state should be
signal finished(next_state: String)

# Label of state for debug display
var label: String


func update(_delta: float) -> void:
	pass

# State physics process
func physics_process(_delta: float) -> void:
	pass

# To be executed when entering the state, along with any additional information the state may want
func enter(payload: Dictionary = {}) -> void:
	pass

# To be executed when exiting the state
func exit() -> void:
	pass
