extends Node

# Mouse capture and pause implementation
@onready var pause_menu = $PauseMenu

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.resume.connect(hide_pause_menu)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not get_tree().paused:
			show_pause_menu()
		else:
			hide_pause_menu()

func show_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	pause_menu.show()

func hide_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.hide()
	get_tree().paused = false
