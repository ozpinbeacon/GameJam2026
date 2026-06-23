extends Node3D
## DOOR ##

##TODO: Door opening SFX

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var teleport_target_marker_3d: Marker3D = $TeleportTargetMarker3D

var door_is_open: bool = false
var teleport_target_position: Transform3D
var is_teleporting: bool = false

@export var camera: Camera3D
@export var teleport_door_partner: Node3D



func _ready() -> void:
	connect_signals()
	
	# Set the teleport target pos as this doors global transform
	teleport_target_position = teleport_target_marker_3d.global_transform



func connect_signals()-> void:
	SignalBus.connect_signal(self, "teleport_complete")


func interact()-> void:
	# Return early if door already open
	if door_is_open:
		return
	
	# Play the animation
	animation_player.play("OpenDoor")
	#audio_stream_player.play()
	
	#Open the other door by playing the animation
	teleport_door_partner.animation_player.play("OpenDoor")
	
	door_is_open = true


func close_door()-> void:
	# Return early if door is already closed
	if door_is_open == false:
		return
	
	# Play the open animation backwards
	animation_player.play_backwards("OpenDoor")
	
	door_is_open = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	# Make sure detected body is a Player
	if body is not Player:
		return
	
	if is_teleporting:
		return
	
	# Find the teleport component in the player scene
	var player_teleport_component
	for child in body.get_children(true):
		if child is TeleportComponent:
			player_teleport_component = child
			break
	
	# Return if no teleport component
	if player_teleport_component == null:
		printerr(name, ": ERROR! Couldnt find teleport component in node: ", body)
		return
	
	is_teleporting = true
	
	# Get the teleport door partners global transform and set it as our teleport target
	var target_transform: Transform3D = teleport_door_partner.teleport_target_position
	
	# Stop the partner door from detecting player
	teleport_door_partner.is_teleporting = true
	
	# Call the function to teleport the player
	player_teleport_component.teleport_to_position(target_transform)
	


func _on_teleport_complete()-> void:
	is_teleporting = false
