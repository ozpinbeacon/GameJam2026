extends Node

# World reference to check for readiness
var world: Node

# Marked progression points
enum Progression {None, FirstNote, FourthNote, AllNotes}

# Initialise game progression
var game_progression: Progression
var no_notes_collected = 0

# Activate listeners for all game event objects
func _ready():
	game_progression = Progression.None
	Events.game_state_event.connect(process_event)

# Receive signal when a poster is collected
func process_event(sender):
	if sender is Poster:
		no_notes_collected += 1
		if no_notes_collected == 1:
			game_progression = Progression.FirstNote
		elif no_notes_collected == 4:
			game_progression = Progression.FourthNote
		elif no_notes_collected == 8:
			game_progression = Progression.AllNotes

func get_state() -> String:
	match self.game_progression:
		Progression.None:
			return "None collected"
		Progression.FirstNote:
			return "First note collected"
		Progression.FourthNote:
			return "Fourth note collected"
		Progression.AllNotes:
			return "All notes collected"
		_:
			return "Unknown"
