extends Node3D
class_name GunGuy

## Gun Guy ##


@onready var animation_player: AnimationPlayer = $GunGuy/AnimationPlayer

func play_intro()-> void:
	animation_player.play(" intro")
	await animation_player.animation_finished
	play_select_one()

func play_select_one()-> void:
	animation_player.play("select_one")
	await animation_player.animation_finished

func play_select_two_from_one()-> void:
	animation_player.play("select_two_from_one")
	await animation_player.animation_finished

func play_select_two_from_three()-> void:
	animation_player.play("select_two_from_three")
	await animation_player.animation_finished

func play_select_three()-> void:
	animation_player.play("select_three")
	await animation_player.animation_finished
