extends Node3D

const LOW_END_FOOT_STEPS = preload("uid://bjpojyt3sgt3d")
const TOP_END_FOOT_STEPS = preload("uid://b200klo1m282e")

@onready var low_end_foot_steps: AudioStreamPlayer3D = $LowEndFootSteps
@onready var top_end_foot_steps: AudioStreamPlayer3D = $TopEndFootSteps

var player_distance_from_monster: float = 0.0
var is_player_in_range: bool = false
var player: Player


#func _process(delta: float) -> void:
	#if not is_player_in_range:
		#return
	#if player == null or is_instance_valid(player) == false:
		#return
	#
	#player_distance_from_monster = player.global_position.distance_to(global_position)
	#clampf(player_distance_from_monster, 0, 100)
	

func play_footstep_sfx()-> void:
	low_end_foot_steps.play()
	top_end_foot_steps.play()
@onready var scream: AudioStreamPlayer3D = $Scream
	
func play_scream_sfx()-> void:
	scream.play()
	


func _on_player_in_range_area_3d_body_entered(body: Node3D) -> void:
	if is_player_in_range:
		return
		
	if body is Player:
		is_player_in_range = true


func _on_player_in_range_area_3d_body_exited(body: Node3D) -> void:
	if is_player_in_range == false:
		return
	
	if body is Player:
		is_player_in_range = false
