class_name GameState extends Node

# Marked progression points
enum Progression {None, FirstItem, SecondItem, ThirdItem, AllItems}

# Initialise game progression
@export var game_progression: Progression
@export var no_items_collected = 0

# Player
@onready var player = get_node("/root/Main/GameWorld/Player")

# Enemy
@onready var enemy = get_node("/root/Main/GameWorld/Enemy")

# Altar
@onready var altar = get_node("/root/Main/GameWorld/Environment/Altar")

# Activate listeners for all game event objects
func _ready():
	# Set zero progression for default
	game_progression = Progression.None
	
	# Get all progression items and listen to their signal
	var event_items = get_parent().find_children("*", "ProgressionItem")
	for item in event_items:
		item.interacted.connect(_key_item_collected)
	
	# Get all player items and listen to their signal
	var player_items = get_parent().find_children("*", "PlayerItem")
	for item in player_items:
		item.interacted.connect(player.process_item)
	
	# Get the altar and listen to it's signal
	var environment_items = get_parent().find_children("*", "EnvironmentalObject")
	for item in environment_items:
		item.interacted.connect(_altar_interacted)
	
	# Listen to the enemy catch signal
	enemy.player_caught.connect(_game_over)

# Receive signal when a poster is collected
func _key_item_collected(sender):
	# Increment items collected
	no_items_collected += 1
	
	# Add the item to the player inventory
	player.add_to_inventory(sender)
	
	# Set progression based on number of items collected
	match no_items_collected:
		1:
			game_progression = Progression.FirstItem
		2:
			game_progression = Progression.SecondItem
		3:
			game_progression = Progression.ThirdItem
		4:
			game_progression = Progression.AllItems


func _altar_interacted() -> void:
	# If the player has any items in their inventory, remove it from their inventory and activate the altar
	if player.inventory:
		player.remove_from_inventory()
		altar.item_added()

# Just a temp test for now
func _game_over() -> void:
	get_tree().paused = true

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
