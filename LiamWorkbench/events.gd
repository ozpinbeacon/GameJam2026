extends Node

signal game_state_event(sender)

enum NoiseType {WALK, RUN, INTERACT, YELL}

signal player_noise(type)
