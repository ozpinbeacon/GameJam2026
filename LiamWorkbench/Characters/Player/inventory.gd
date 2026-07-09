class_name Inventory extends Node

# Signal to send to player when an item is picked up
signal item_received

# Sub classes for different types of items
var consumables: Consumables
var key_items: KeyItems
var progression_items: ProgressionItems

# Init sub classes
func _init() -> void:
	self.consumables = Consumables.new()
	self.key_items = KeyItems.new()
	self.progression_items = ProgressionItems.new()

# To be called by the game state
func process_item(item_type) -> void:
	match item_type:
		# If a lantern, enable lantern for player and tell player to enable lantern
		PlayerItem.ITEM_TYPES.Lantern:
			self.key_items.lantern = true
			item_received.emit(PlayerItem.ITEM_TYPES.Lantern)
		# If pills, add one to inventory
		PlayerItem.ITEM_TYPES.Pills:
			self.consumables.pills += 1
		_:
			pass

# DEBUG
func list_inventory() -> String:
	var inventory_str = "\n"
	inventory_str += "Consumables\n"
	for prop in self.consumables.get_property_list():
		if prop.type == Variant.Type.TYPE_INT: 
			var prop_value = self.consumables.get(prop.name)
			inventory_str += prop.name + ": " + str(prop_value) + "\n"
	inventory_str += "Key Items\n"
	for prop in self.key_items.get_property_list():
		if prop.type == Variant.Type.TYPE_BOOL:
			var prop_value = self.key_items.get(prop.name)
			inventory_str += prop.name + ": " + str(prop_value) + "\n"
	inventory_str += "Progression Items\n"
	for prop in self.progression_items.get_property_list():
		if prop.type == Variant.Type.TYPE_BOOL:
			var prop_value = self.progression_items.get(prop.name)
			inventory_str += prop.name + ": " + str(prop_value) + "\n"
	return inventory_str

# Export all inventory items to editor for debug testing
class Consumables:
	@export var holy_water: int = 0
	@export var pills: int = 0

class KeyItems:
	@export var lantern: bool = false
	@export var mb_wand: bool = false

class ProgressionItems:
	@export var heart: bool = false
	@export var brain: bool = false
	@export var eyes: bool = false
	@export var lungs: bool = false
	
	# Signal receiver from game state, if item matches one of the progression items, add it to inventory
	func add_to_inventory(item_name: StringName) -> void:
		var prop_name = item_name.to_lower()
		var prop = self.get(prop_name)
		if prop != null:
			self.set(prop_name, true)
			
	# Remove the first valid item from inventory
	func remove_from_inventory() -> String:
		var inventory = _get_available_key_items()
		if inventory:
			self.set(inventory[0], false)
			return inventory[0]
		else:
			return ""
	
	# List out any items that return true	
	func _get_available_key_items() -> Array[StringName]:
		# Array must be of StringName to use set() function
		var available_items: Array[StringName] = []
		# Get all properties of ProgressionItems
		for prop in self.get_property_list():
			var prop_value = self.get(prop.name)
			# Only return our Bool properties and only if true
			if prop.type == Variant.Type.TYPE_BOOL and prop_value == true:
				available_items.append(prop.name)
		
		return available_items
	
