class_name StudioInventorySlot
extends Resource

@export var item: ItemData
@export var amount: int = 0

func is_empty() -> bool:
	return item == null or amount <= 0

func can_stack_with(other_item: ItemData) -> bool:
	return item != null and other_item != null and item.id == other_item.id and item.stackable

func save() -> Dictionary:
	if item == null:
		return {}
	return {
		"item_id": item.id,
		"amount": amount,
	}
