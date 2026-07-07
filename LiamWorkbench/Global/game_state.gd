class_name GameState extends Node

# Marked progression points
enum Progression {None, FirstItem, SecondItem, ThirdItem, AllItems}

# Initialise game progression
@export var game_progression: Progression
@export var no_items_collected = 0

# Player
@onready var player = get_node("/root/Main/GameWorld/Player")

# Activate listeners for all game event objects
func _ready():
	game_progression = Progression.None
	var event_items = get_parent().find_children("*", "ProgressionItem")
	for item in event_items:
		item.interacted.connect(key_item_collected)
	
	var player_items = get_parent().find_children("*", "PlayerItem")
	for item in player_items:
		item.interacted.connect(player._process_item)

# Receive signal when a poster is collected
func key_item_collected(sender):
	no_items_collected += 1
	match no_items_collected:
		1:
			game_progression = Progression.FirstItem
		2:
			game_progression = Progression.SecondItem
		3:
			game_progression = Progression.ThirdItem
		4:
			game_progression = Progression.AllItems
	

# Helper function for debugging current progression state
func get_state() -> String:
	match self.game_progression:
		Progression.None:
			return "None collected"
		Progression.FirstItem:
			return "First item collected"
		Progression.SecondItem:
			return "Second item collected"
		Progression.ThirdItem:
			return "Third item collected"
		Progression.AllItems:
			return "All items collected"
		_:
			return "Unknown"
