extends Control

signal resume

@onready var main_pause_menu = $MainPauseMenu
@onready var resume_button = $MainPauseMenu/Resume
@onready var quit_button = $MainPauseMenu/Quit

@onready var confirmation_menu = $ConfirmationMenu
@onready var confirmation_yes = $ConfirmationMenu/Yes
@onready var confirmation_no = $ConfirmationMenu/No

func _ready() -> void:
	resume_button.pressed.connect(resume_game)
	quit_button.pressed.connect(show_confirmation)
	confirmation_yes.pressed.connect(quit_game)
	confirmation_no.pressed.connect(hide_confirmation)

func _process(delta) -> void:
	if Input.is_action_pressed("quit"):
		get_viewport().set_input_as_handled()
		if not confirmation_menu.visible:
			show_confirmation()
		else:
			quit_game()

func show_confirmation() -> void:
	main_pause_menu.hide()
	confirmation_menu.show()

func hide_confirmation() -> void:
	confirmation_menu.hide()
	main_pause_menu.show()

func resume_game() -> void:
	resume.emit()

func quit_game() -> void:
	get_tree().quit()
