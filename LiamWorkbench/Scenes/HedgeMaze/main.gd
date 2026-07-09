extends Node

# Pause menu reference
@onready var pause_menu = $UI/PauseMenu
# In game UI reference
@onready var in_game_ui = $UI/InGameUI

# Cursor UI
@onready var cursor_label = $UI/InGameUI/CursorLabel
# Player reference
@onready var player = $GameWorld/Player

# Capture mouse and set process
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.resume.connect(hide_pause_menu)
	
	player.cursor_label_update.connect(cursor_label.update_label)

# If ESC is pressed, pause tree and show pause menu
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not get_tree().paused:
			show_pause_menu()
		else:
			hide_pause_menu()

func show_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	in_game_ui.hide()
	pause_menu.show()

func hide_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.hide()
	in_game_ui.show()
	get_tree().paused = false
