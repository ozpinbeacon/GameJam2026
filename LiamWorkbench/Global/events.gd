extends Node

# An event for changing the current state of the game
signal game_state_event(sender)

# Player noise emission
enum NoiseType {CROUCH_WALK, WALK, RUN, INTERACT, YELL}

signal player_noise(type)
