extends CharacterBody3D
class_name Player #Creates a custom class called Player. 


#region Ethans Explanations and stuff (click the arrow to the left to show/hide)
## Custom Class 'Player' ##
"""Making 'Player' its own custom class enables editor hints when you hover
 over one of my functions in other scripts you can see my comments aswell as
autofilling when typing function names or variable names.
This script is the base level script and is attatched to all nodes of this 
class. You can attatch anpther script to a Player node to add more 
functionality and still have access to functions and variables in this 
base script. Also makes it able to filter for only nodes of this class if I want
"""
#endregion


#region Constants and Variables
## Constants ##
const SPEED: float = 9.0
const JUMP_VELOCITY: float = 10.0
const SLIDE_JUMP_Y_VELOCITY = 12.0
const SLIDE_JUMP_HORIZONTAL_VELOCITY_MULTIPLIER: float = 1.2##Multiplied by players horizontal velocity for a quick boost
const MAX_SLIDE_JUMP_HORIZONTAL_VELOCITY: float = 12
const IN_AIR_SPEED: float = 6.0
const ACCELERATION: float = 30
const DECELERATION: float = 42
const ROTATION_INTERPOLATE_SPEED: float = 10.0 #Multiplied by delta to get the amount of rotation to slerp by
const JUMP_GRAVITY_MULTIPLIER: float = 2.2
const FALL_GRAVITY_MULTIPLIER: float = 2.4
const SLIDE_SPEED: float = 16.0
const SLIDE_DURATION: float = 1.2
const SLIDE_DECELERATION: float = 10.0


## Variables ##
# Player
var player_ready: bool = false## Set to true after _ready() has finished (useful for making sure player before loading stuff)
var player_disabled: bool = false## Stops player input and movement, disable player by broadcasting player_disabled signal

# Player Mesh
var orientation: Transform3D = Transform3D()## Dummy transform that all transformations are made to before applying directly to the players mesh

# Object detection and interaction
var detected_interactable_component: Object##Objects detected by the raycast are stored here for Players Scripts to access
var action_cooling_down: bool = false## Prevents multiple fires when player clicks or performs an action
var action_cooldown_time: float = 0.6## Resets the action cooldown variable on timeout

# Detecting other nodes and objects
var footcast_cooling_down: bool = false## Prevents jittering and multiple fires when trying to move the player upwards to move past a tiny ledge that shouldnt prevent movement


## Exported variables ##
@export_subgroup("DEBUG STUFF")
@export var debug: bool = false

@export_subgroup("State Machine")
@export var state_machine: StateMachine

@export_subgroup("3D Mesh")
@export var player_model: Node3D

@export_subgroup("SFX")
@export var player_sfx: CharacterSFXPlayer## Customn class for handling playing all players SFX
@export var foots_steps_SFX: AudioStreamPlayer3D

@export_subgroup("Camera Stuff")
@export var player_camera: Camera3D## Drag and drop the players camera here
@export var target_reticle_node: Sprite3D## Drag and drop the sprite3D that holds the crosshair texture here
@export var target_reticle_texture: Texture2D## Drag and drop the image of the crosshair here
#endregion



#region Initial Player Setup
func _ready() -> void:
	#Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Connect to required global signals
	connect_signals()
	
	# Store current cam in GameManager for access throughout the game
	player_camera.make_current()
	GameManager.current_camera = player_camera

	# Player is ready, broadcast signal and pass this node as a parameter
	player_ready = true
	SignalBus.broadcast_signal("player_ready", [self])

func connect_signals() -> void:
	SignalBus.connect_signal(self, "enable_player")
	SignalBus.connect_signal(self, "disable_player")
	SignalBus.connect_signal(self, "change_player_state")
	SignalBus.connect_signal(self, "fire_one_shot_animation")
#endregion


#region Enable/Disable Player
func _on_disable_player(_can_look: bool = false) -> void:
	if debug: print("PLAYER: Disabling Player")
	
	# Change to idle state
	#if state_machine.current_state and state_machine.current_state.state_name != "ON_GROUND":
		#state_machine.request_new_state("ON_GROUND")
	
	# Stop any SFX playing
	if foots_steps_SFX.playing:
		foots_steps_SFX.stop()
	if player_sfx.playing:
		player_sfx.stop()
	
	# Hide the reticle
	target_reticle_node.hide()
	
	# Set the player to disabled
	player_disabled = true

func _on_enable_player() -> void:
	if debug: print("PLAYER: Enabling Player")
	
	# Show the target reticle
	target_reticle_node.show()
	
	# Set the player to enabled
	player_disabled = false
#endregion


#region Input and interactng with objects
func _input(event: InputEvent) -> void:
	# Check that event is mouse, that it was left mouse button  and that it was clicked
	if event is not InputEventMouseButton or event.button_index != 1 or not event.pressed: 
		return
	
	#Check if raycast is detecting an interactable object and make sure it has an interact() function
	if detected_interactable_component and detected_interactable_component.has_method("interact"):
		
		# Prevent retriggering multiple times from one click
		if action_cooling_down: return
			
		# PLay the sfx and call the function on the object
		player_sfx.play_sfx("interact")
		detected_interactable_component.interact()
		
		# Start the cooldown timer to prevent multiple clicks
		action_cooling_down = true
		get_tree().create_timer(action_cooldown_time).timeout.connect(_on_action_cooldown_timeout)
		return


func _on_action_cooldown_timeout()-> void:
	# Reset this after timer finishes to enable actions again
	action_cooling_down = false
#endregion
