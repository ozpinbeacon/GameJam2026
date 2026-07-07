extends Node3D
## Main Menu ##

const LEFT: String = "left"
const RIGHT: String = "right"
const START_GAME: String = "start_game"
const OPTIONS: String = "options"
const QUIT_GAME: String = "quit_game"

const ENVIRONMENT_BRIGHTNESS_PROPERTY_PATH: String = "environment:adjustment_brightness"
const ENVIRONMENT_CONTRAST_PROPERTY_PATH: String = "environment:adjustment_contrast"
const ENVIRONMENT_SATURATION_PROPERTY_PATH: String = "environment:adjustment_saturation"

const SUN_COLOR_PROPERTY_PATH: String = "light_color"
const SUN_COLOR_RED: Color = Color(0.62, 0.294, 0.184)
const SUN_COLOR_WHITE: Color = Color(1.0, 1.0, 1.0)

@onready var camera_intro: Camera3D = $Cameras/CameraIntro
@onready var camera_hanging_guy: Camera3D = $Cameras/CameraHangingGuy
@onready var camera_hanging_guy_zoomed_out: Camera3D = $Cameras/CameraHangingGuyZoomedOut
@onready var camera_chair_guy: Camera3D = $Cameras/CameraChairGuy
@onready var camera_chair_guy_zoomed_out: Camera3D = $Cameras/CameraChairGuyZoomedOut
@onready var camera_gun_guy: Camera3D = $Cameras/CameraGunGuy
@onready var camera_gun_guy_zoomed_out: Camera3D = $Cameras/CameraGunGuyZoomedOut

@onready var animated_overlay_start_game: TextureRect = $CanvasLayer/Control/AnimatedOverlayStartGame
@onready var animated_overlay_options: TextureRect = $CanvasLayer/Control/AnimatedOverlayOptions
@onready var animated_overlay_quit_game: TextureRect = $CanvasLayer/Control/AnimatedOverlayQuitGame

@onready var world_environment: WorldEnvironment = $Environment/WorldEnvironment
@onready var sun: DirectionalLight3D = $Environment/Sun

@onready var gun_guy: GunGuy = $MainMenuV2/GunGuy2
@onready var hanging_guy: Node3D = $MainMenuV2/HangingGuy
@onready var chair_guy_animation_player: AnimationPlayer = $MainMenuV2/ChairGuy/AnimationPlayer

@onready var main_audio_stream_player: AudioStreamPlayer = $MainAudioStreamPlayer
@onready var intro_audio_stream_player: AudioStreamPlayer = $IntroAudioStreamPlayer
@onready var select_sfx: AudioStreamPlayer = $SelectSFX
@onready var change_selection_sfx: AudioStreamPlayer = $ChangeSelectionSFX


var transitioning: bool = true
var currently_selected: String
var freeze_frame_active: bool = false


@export var start_game_camera_transition_time: float = 0.9
@export var options_camera_transition_time: float = 0.9
@export var quit_game_camera_transition_time: float = 0.9
@export var zoom_out_time: float = 0.5
@export var zoom_in_time: float = 0.5

@export var activate_freeze_frame_tween_time: float = 0.1
@export var freeze_brightness_value: float = 0.8
@export var freeze_contrast_value: float = 1.25
@export var freeze_saturation_value: float = 0.0

@export var deactivate_freeze_frame_tween_time: float = 0.1
@export var default_brightness_value: float = 1.0
@export var default_contrast_value: float = 1.0
@export var default_saturation_value: float = 1.0



#region Initiialisation
func _ready() -> void:
	setup_main_menu_initial_state()


func setup_main_menu_initial_state()-> void:
	# Transition to START_GAME state
	transitioning = true
	currently_selected = START_GAME
	
	sun.set("light_color", SUN_COLOR_RED)
	
	camera_intro.make_current()
	
	intro_audio_stream_player.finished.connect(on_intro_audio_stream_player_finished)
	intro_audio_stream_player.play()
	
	await gun_guy.play_intro()
	
	# Transition cameras
	await CameraSwitcher.transition_camera_3d(camera_intro, camera_hanging_guy_zoomed_out, 0.5)
	await CameraSwitcher.transition_camera_3d(camera_hanging_guy_zoomed_out, camera_hanging_guy, 0.5)
		
	await activate_freeze_frame_state()
	
	await get_tree().create_timer(1.0).timeout
	
	animated_overlay_options.hide()
	animated_overlay_quit_game.hide()
	animated_overlay_start_game.show()
	
	transitioning = false
	
func on_intro_audio_stream_player_finished()-> void:
	main_audio_stream_player.play()
#endregion



#region Handling Input
func _input(event: InputEvent) -> void:
	if transitioning:
		return

	if event.is_action_pressed("ui_accept"):
		transitioning = true
		confirm_selection()
	
	if event.is_action_pressed("left"):
		print("Left pressed")
		change_selection_sfx.play()
		select_left()
		
	if event.is_action_pressed("right"):
		print("Right pressed")
		change_selection_sfx.play()
		select_right()
	

func select_left()-> void:
	print("select_left() called")
	match currently_selected:
		START_GAME:
			return
		OPTIONS:
			animated_overlay_options.hide()
			chair_guy_animation_player.play("LookDown")
			select_start_game()
		QUIT_GAME:
			animated_overlay_quit_game.hide()
			select_options()
		_:
			printerr("ERROR Currently selected doesnt compute: ", currently_selected)
			return


func select_right()-> void:
	print("select_right() called")
	match currently_selected:
		START_GAME:
			animated_overlay_start_game.hide()
			select_options()
		OPTIONS:
			animated_overlay_options.hide()
			chair_guy_animation_player.play("LookDown")
			select_quit_game()
		QUIT_GAME:
			return
		_:
			printerr("ERROR Currently selected doesnt compute: ", currently_selected)
			return
#endregion



#region Selecting Menu Options
func select_start_game()-> void:
	print("Selecting start game now")
	
	# Prevent fucking with the game until transition complete
	transitioning = true
	
	# Set the environment and lights to freeze frame if not already
	if freeze_frame_active:
		await deactivate_freeze_frame_state()
	
	# Zoom out to gun guy camera 2
	await CameraSwitcher.transition_camera_3d(get_viewport().get_camera_3d(), camera_hanging_guy_zoomed_out, zoom_out_time)
	
	# Update the variable to store the current menu selection
	currently_selected = START_GAME
	
	# Play the animation and wait for it to finish
	await gun_guy.play_select_one()
	
	# Zoom in on the next camera
	await CameraSwitcher.transition_camera_3d(camera_hanging_guy_zoomed_out, camera_hanging_guy, zoom_in_time)
	
	#Change the environment and light settings
	await activate_freeze_frame_state()
	
	# Handle the graphics overlay
	animated_overlay_options.hide()
	animated_overlay_quit_game.hide()
	animated_overlay_start_game.show()
	
	# Allow to reset back after tiny delay
	await get_tree().create_timer(0.2).timeout
	transitioning = false


func select_options()-> void:
	print("Selecting options now")
	# Prevent fucking with it until transition complete
	transitioning = true
	
	# Set the environment and lights to freeze frame if not already
	if freeze_frame_active:
		await deactivate_freeze_frame_state()
	
	# Zoom out 
	if currently_selected == QUIT_GAME:
		await CameraSwitcher.transition_camera_3d(get_viewport().get_camera_3d(), camera_gun_guy_zoomed_out, zoom_out_time)
	elif currently_selected == START_GAME:
		await CameraSwitcher.transition_camera_3d(get_viewport().get_camera_3d(), camera_hanging_guy_zoomed_out, zoom_out_time)
	
	# Zoom in on the next camera
	await CameraSwitcher.transition_camera_3d(get_viewport().get_camera_3d(), camera_chair_guy, zoom_in_time)
	
	# Play the chair guys animation
	chair_guy_animation_player.play("LookUp")
	
	# Play the gun guys animation and wait for it to finish
	if currently_selected == QUIT_GAME:
		await gun_guy.play_select_two_from_three()
	elif currently_selected == START_GAME:
		await gun_guy.play_select_two_from_one()
	
	# Update the variable to store the current menu selection
	currently_selected = OPTIONS
	
	#Change the environment and light settings
	await activate_freeze_frame_state()
	
	# Handle the graphics overlay
	animated_overlay_options.show()
	animated_overlay_quit_game.hide()
	animated_overlay_start_game.hide()

	# Allow to reset back after tiny delay
	await get_tree().create_timer(0.2).timeout
	transitioning = false
	

func select_quit_game()-> void:
	print("Selecting quit game now")
	# Prevent fucking with it until transition complete
	transitioning = true
	
	# Set the environment and lights to freeze frame if not already
	if freeze_frame_active:
		await deactivate_freeze_frame_state()
	
	# Zoom out to gun guys camera
	await CameraSwitcher.transition_camera_3d(get_viewport().get_camera_3d(), camera_chair_guy_zoomed_out, zoom_out_time)
	
	# Update the variable to store the current menu selection
	currently_selected = QUIT_GAME
	
	# Zoom in on the next camera
	await CameraSwitcher.transition_camera_3d(camera_chair_guy_zoomed_out, camera_gun_guy, zoom_in_time)
	
	# Play the animations and wait for it to finish
	await gun_guy.play_select_three()
	
	#Change the environment and light settings
	await activate_freeze_frame_state()
	
	# Handle the graphics overlay
	animated_overlay_options.hide()
	animated_overlay_quit_game.show()
	animated_overlay_start_game.hide()
	
	# Allow to reset back after tiny delay
	await get_tree().create_timer(0.2).timeout
	transitioning = false
#endregion



#region Player Pressed Enter. Selection has been made
func confirm_selection()-> void:
	print("Enter pressed! Confirmed selection: ", currently_selected)
	match currently_selected:
		START_GAME:
			start_game()
		OPTIONS:
			open_options()
		QUIT_GAME:
			quit_game()

@onready var hanging_guy_movement_animation_player: AnimationPlayer = $MainMenuV2/HangingGuy/HangingGuyMovementAnimationPlayer

func start_game()-> void:
	print("starting game now")
	await deactivate_freeze_frame_state()
	#await gun_guy.play_shoot_hanging_guy()
	await hanging_guy.play_fall_from_ropes()
	hanging_guy.play_running_loop()
	hanging_guy_movement_animation_player.play("move_hanging_guy")
	await hanging_guy_movement_animation_player.animation_finished
	
	hanging_guy.play_door_smash()
	await get_tree().create_timer(0.5).timeout
	hanging_guy_movement_animation_player.play("leave_mansion")
	hanging_guy.play_running_loop()
	
	
	#await hanging_guy.play_escape()
	#load_scene(game_level)

func open_options()-> void:
	print("opening options menu")
	await deactivate_freeze_frame_state()
	#gun_guy.play("shoot_chair_guy")
	#await gun_guy.animation_finished
	#load_scene(options)

func quit_game()-> void:
	print("quitting game now")
	await deactivate_freeze_frame_state()
	#gun_guy.play("shoot_self")
	#await gun_guy.animation_finished
	#get_tree().quit()
#endregion



#region Freeze Frame
func activate_freeze_frame_state()-> void:
	# Create the tween and set it to tween all properties simultaneously (in paralel)
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Tween the environment properties
	tween.tween_property(world_environment, ENVIRONMENT_BRIGHTNESS_PROPERTY_PATH, freeze_brightness_value, activate_freeze_frame_tween_time)
	tween.tween_property(world_environment, ENVIRONMENT_CONTRAST_PROPERTY_PATH, freeze_contrast_value, activate_freeze_frame_tween_time)
	tween.tween_property(world_environment, ENVIRONMENT_SATURATION_PROPERTY_PATH, freeze_saturation_value, activate_freeze_frame_tween_time)
	
	# Tween the suns color
	tween.tween_property(sun, SUN_COLOR_PROPERTY_PATH, SUN_COLOR_WHITE, activate_freeze_frame_tween_time)
	
	# Make this functino async so it can be awaited
	await tween.finished
	
	freeze_frame_active = true
	
	sun.show()


func deactivate_freeze_frame_state()-> void:
	# Create the tween and set it to tween all properties simultaneously (in paralel)
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Tween the environment properties
	tween.tween_property(world_environment, ENVIRONMENT_BRIGHTNESS_PROPERTY_PATH, default_brightness_value, deactivate_freeze_frame_tween_time)
	tween.tween_property(world_environment, ENVIRONMENT_CONTRAST_PROPERTY_PATH, default_contrast_value, deactivate_freeze_frame_tween_time)
	tween.tween_property(world_environment, ENVIRONMENT_SATURATION_PROPERTY_PATH, default_saturation_value, deactivate_freeze_frame_tween_time)
	
	# Tween the suns color
	tween.tween_property(sun, SUN_COLOR_PROPERTY_PATH, SUN_COLOR_RED, deactivate_freeze_frame_tween_time)
	
	# Make this functino async so it can be awaited
	await tween.finished
	
	freeze_frame_active = false
	
	sun.hide()
#endregion
