extends AudioStreamPlayer
class_name CharacterSFXPlayer
## PLAYS SFX FOR THE PLAYER... OBVIS  ##

@export var sfx_array: Array[SFX]##Add SFX resource for each SFX this player needs to play
@export var max_sounds_that_can_play_at_once: int = 8

func _ready() -> void:
	# Enable polyphony for this player (multiple sounds at once but can only be one sound file)
	set("max_polyphony", max_sounds_that_can_play_at_once)


func play_sfx(requested_sfx_name: String)-> void:
	if sfx_array.is_empty():
		printerr(name, ": ERROR trying to play: ", requested_sfx_name, ". SFX array is empty. Add SFX to array in exported variable.")
		return
	
	var sfx: SFX = find_sfx_in_array_or_return_null(requested_sfx_name)
	if sfx == null:
		return
	
	set("stream", sfx.audio_file)
	play()
	
	
func find_sfx_in_array_or_return_null(requested_sfx_name: String)-> SFX:
	# Either finds and returns the SFX from the array or returns null and fails quietly
	for sfx in sfx_array:
		if sfx.SFX_name == requested_sfx_name:
			return sfx
	
	printerr(name, ": ERROR! Couldnt find SFX in array: ", requested_sfx_name, ". Returning Null")
	return null
