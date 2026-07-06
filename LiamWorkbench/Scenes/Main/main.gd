extends Control

@onready var mazeButton: Button = $Maze
@onready var testingButton: Button = $Testing

func _ready() -> void:
	$Maze.pressed.connect(_transition_to_maze)
	$Testing.pressed.connect(_transition_to_test)

func _transition_to_test() -> void:
	get_tree().change_scene_to_file("res://Scenes/Testing/Main.tscn")

func _transition_to_maze() -> void:
	get_tree().change_scene_to_file("res://Scenes/HedgeMaze/hedge_maze.tscn")
