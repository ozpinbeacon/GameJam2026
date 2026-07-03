class_name InteractableObject extends StaticBody3D

# Label to show when cursor collides
var label

# What type of object is this
enum ObjectType {World, Progression, Player}
var object_type: ObjectType

# If player type, node references back to player for interaction
var player: Node
var player_item: Node

# Set variables depending on type of object
func _ready():
	match self.object_type:
		ObjectType.World:
			pass
		ObjectType.Progression:
			pass
		ObjectType.Player:
			# Node reference for player object
			self.player = get_node(NodePath("/root/Global/Main/Player"))
			

# Interaction function for when player clicks on item
func interact() -> void:
	if self.object_type == ObjectType.Progression:
		Events.game_state_event.emit(self)
	self.call_deferred("queue_free")
