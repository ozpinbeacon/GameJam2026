extends Node

var player: PlayerSettings
var config

func _init():
	self.player = PlayerSettings.new()
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err != OK:
		set_defaults()
	else:
		load_from_settings()

func load_from_settings() -> void:
	self.player.CAMERA_ACCELERATION = config.get_value("player", "CAMERA_ACCELERATION")
	self.player.CAMERA_CONTROLLER_ROTATION_SPEED = config.get_value("player", "CAMERA_CONTROLLER_ROTATION_SPEED")
	self.player.CAMERA_MOUSE_SENSITIVITY = config.get_value("player", "CAMERA_MOUSE_SENSITIVITY")
	self.player.MOUSE_KEYBOARD_CONTROLS = config.get_value("player", "MOUSE_KEYBOARD_CONTROLS")

func set_defaults() -> void:
	self.player.set_defaults()

class PlayerSettings:
	# Control settings
	var CAMERA_CONTROLLER_ROTATION_SPEED: int
	var CAMERA_MOUSE_SENSITIVITY: float
	var CAMERA_ACCELERATION: int
	var MOUSE_KEYBOARD_CONTROLS: bool
			
	func set_defaults() -> void:
		self.CAMERA_ACCELERATION = 2
		self.CAMERA_CONTROLLER_ROTATION_SPEED = 3
		self.CAMERA_MOUSE_SENSITIVITY = 0.25
		self.MOUSE_KEYBOARD_CONTROLS = true
