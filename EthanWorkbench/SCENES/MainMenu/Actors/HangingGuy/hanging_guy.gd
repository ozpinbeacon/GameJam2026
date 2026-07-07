extends Node3D
@onready var animation_player: AnimationPlayer = $HangingGuy/AnimationPlayer


func play_fall_from_ropes()-> void:
	animation_player.play("FallFromRopes")
	await animation_player.animation_finished

func play_running_loop()-> void:
	animation_player.play("Running")

func play_door_smash()-> void:
	animation_player.play("SmashDoor")
