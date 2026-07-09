class_name Inventory extends Node

signal item_received

var consumables: Consumables
var key_items: KeyItems
var progression_items: ProgressionItems

func _init() -> void:
	self.consumables = Consumables.new()
	self.key_items = KeyItems.new()
	self.progression_items = ProgressionItems.new()

# To be called by game state, if lantern turn on lantern function
func process_item(item_type) -> void:
	match item_type:
		PlayerItem.ITEM_TYPES.Lantern:
			self.key_items.lantern = true
			item_received.emit(PlayerItem.ITEM_TYPES.Lantern)
		PlayerItem.ITEM_TYPES.Pills:
			self.consumables.pills += 1
		_:
			pass

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
	
	func add_to_inventory(item_name: StringName) -> void:
		var prop_name = item_name.to_lower()
		var prop = self.get(prop_name)
		if prop != null:
			self.set(prop_name, true)
			
	func remove_from_inventory() -> void:
		var inventory = _get_available_key_items()
		if inventory:
			self.set(inventory[0], false)		
			
	func _get_available_key_items() -> Array[StringName]:
		var available_items = []
		for item in self.get_property_list():
			if self.get(item.name):
				available_items.append(item.name)
		
		return available_items
	
