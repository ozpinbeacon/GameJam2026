extends Node3D

@onready var animation_player: AnimationPlayer = $BigFknTree/AnimationPlayer

func _ready() -> void:
	get_tree().create_timer(randf_range(0,3)).timeout.connect(start_animation)
	
func start_animation()-> void:	
	animation_player.play("MoveTreeA")
