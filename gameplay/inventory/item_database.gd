class_name ItemDatabase
extends Resource

@export var items: Array[ItemData] = []

func get_item(item_id: String) -> ItemData:
	for item: ItemData in items:
		if item != null and item.id == item_id:
			return item
	return null

func to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	for item: ItemData in items:
		if item != null and not item.id.is_empty():
			result[item.id] = item
	return result
