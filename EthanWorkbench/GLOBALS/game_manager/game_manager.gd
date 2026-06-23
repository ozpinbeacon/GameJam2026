extends Node
## Game Manager ##

"""
Accessible from any node project wide. Useful for storing refernces to 
nodes and other information for access throughout the game. Always running
while the game is open. All variables are persistent until game is closed
""" 

# Variables #
var player: CharacterBody3D## Assigned via Signal from players _ready() function
var current_camera: Camera3D## Assigned via player script when switching cameras using Global CameraSwitcher functions
var current_world_environment_node: WorldEnvironment## The environment node used for setting and adjusting light, fog and colour settings


# Setup #
func _ready() -> void:
	connect_signals()

func connect_signals()-> void:## Register this node to react to signals broadcast by the Global Signal Bus
	SignalBus.connect_signal(self, "player_ready")



# Functions called on recieving signals #
func _on_player_ready(_player: CharacterBody3D)-> void:## player_ready Signal recieved from SignalBus
	player = _player
	print("GM: player_ready signal recieved. sotring reference to player node. player: ", player)
