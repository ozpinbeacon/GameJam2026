extends Area3D
class_name InteractableComponent
"""
TODO WRITE THIS EXPLANATION 
"""

#const SFX_DETECT = preload("uid://bg5nspnpffttf")
#const SFX_INTERACT = preload("uid://dcds1jpo3o6th")

@export_category("Parent Node Reference")
@export var parent: Node

@export_category("SFX")
@export var play_SFX_on_highlight: bool = true
@export var highlight_audio_player: AudioStreamPlayer
@export var highlight_SFX: AudioStream

@export var play_SFX_on_interact: bool = true
@export var interact_audio_player: AudioStreamPlayer
@export var interact_SFX: AudioStream

@export_category("Highlight Mesh")
@export var highlight_meshs: Array[MeshInstance3D]## Place all meshs that the highlight should be applied to into this array
@export_enum("BLUE", "RED", "GREEN")var highlight_colour: String## Select a colour for the highlight

@export_category("UI hints")
@export var show_ui_hint_on_highlight: bool = false## Shows a UI element when object is targeted by player
@export var highlight_ui_name: StringName## Passed as a parameter to the UI global class so it knows which UI element to animate in

@export var show_ui_hint_on_interact: bool = false## Shows a UI element when object is interacted with
@export var interact_ui_name: StringName## Passed as a parameter to the UI global class so it knows which UI element to animate in
@export var remove_interact_ui_hint_on_timer: bool = false
@export var remove_ui_hint_timer: float = 4.0




const HIGHLIGHT_MATERIALS = {
	"BLUE": preload("uid://bql044o87a85i"),
	"RED": preload("uid://cmssfase2emhl"),
	"GREEN": preload("uid://ck0qki0fxvsrv")
}


func _ready() -> void:
	# Set the collision layer so area3D can be detected
	set_collision_layer_value(2, true)
	
	# Set the audio streams for the SFX
	interact_audio_player.set("stream", interact_SFX)
	highlight_audio_player.set("stream", highlight_SFX)
	#set("monitoring", false)


	
	


func highlight_object()-> void:
	print("INTERACTABLE COMPONENT RECIEVED REQUEST TO HIGHLIGHT MESH")
	var highlight_material = HIGHLIGHT_MATERIALS.get(highlight_colour)
	for mesh in highlight_meshs:
		mesh.set_material_overlay(highlight_material)
	if show_ui_hint_on_highlight:
		print(name, ": Showing UI hint for parent object highlighted. parent: ", parent)
		##TODO UI.animate UI
	if play_SFX_on_highlight:
		highlight_audio_player.play()


func remove_highlight()-> void:
	print("INTERACTABLE COMPONENT RECIEVED REQUEST TO REMOVE HIGHLIGHT FROM MESH")
	for mesh in highlight_meshs:
		mesh.material_overlay = null
	if show_ui_hint_on_highlight:
		print(name, ": Hiding UI hint for parent object highlighted. parent: ", parent)

func interact()-> void:
	print("INTERACTING WITH PARENT: ", parent.name)
	# Show the UI if enabled
	if show_ui_hint_on_interact:
		print(name, ": Showing UI hint for parent object interaction. parent: ", parent)
	
	# Start the timer to remove the UI if enabled
	if remove_interact_ui_hint_on_timer:
		get_tree().create_timer(remove_ui_hint_timer).timeout.connect(remove_interact_ui_hint)
	
	#Play the SFX if enabled
	if play_SFX_on_interact:
		interact_audio_player.play()
	
	# Call the parents interact function
	if not parent.has_method("interact"):
		printerr(self, ": ERROR! No interact() function on parent node: ", parent)	
	parent.interact()
	


func remove_interact_ui_hint()-> void:
	print(self, ": timer has timed out. Removing interact UI hint now")
	##TODO UI.remove UI element
