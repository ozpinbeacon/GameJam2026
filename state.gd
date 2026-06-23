class_name State extends Node

signal finished(next_state: String)

var label: String

func update(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func enter(payload: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass
