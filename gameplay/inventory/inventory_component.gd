class_name InventoryComponent
extends Node

signal item_added(item: ItemData, amount: int)
signal item_removed(item: ItemData, amount: int)
signal inventory_changed

@export var capacity: int = 20

var slots: Array[StudioInventorySlot] = []

func add_item(item: ItemData, amount: int = 1) -> bool:
	if item == null or amount <= 0:
		return false

	if item.stackable:
		var stack_slot: StudioInventorySlot = _find_slot(item.id)
		if stack_slot != null:
			var new_amount: int = min(stack_slot.amount + amount, item.max_stack)
			var added: int = new_amount - stack_slot.amount
			stack_slot.amount = new_amount
			item_added.emit(item, added)
			inventory_changed.emit()
			return added == amount

	if slots.size() >= capacity:
		return false

	var slot: StudioInventorySlot = StudioInventorySlot.new()
	slot.item = item
	slot.amount = amount
	slots.append(slot)
	item_added.emit(item, amount)
	inventory_changed.emit()
	return true

func remove_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false

	var slot: StudioInventorySlot = _find_slot(item_id)
	if slot == null or slot.amount < amount:
		return false

	slot.amount -= amount
	var removed_item: ItemData = slot.item
	if slot.amount <= 0:
		slots.erase(slot)
	item_removed.emit(removed_item, amount)
	inventory_changed.emit()
	return true

func has_item(item_id: String, amount: int = 1) -> bool:
	var slot: StudioInventorySlot = _find_slot(item_id)
	return slot != null and slot.amount >= amount

func get_item(item_id: String) -> ItemData:
	var slot: StudioInventorySlot = _find_slot(item_id)
	if slot == null:
		return null
	return slot.item

func get_amount(item_id: String) -> int:
	var slot: StudioInventorySlot = _find_slot(item_id)
	if slot == null:
		return 0
	return slot.amount

func clear() -> void:
	slots.clear()
	inventory_changed.emit()

func save() -> Dictionary:
	var saved_slots: Array[Dictionary] = []
	for slot: StudioInventorySlot in slots:
		if not slot.is_empty():
			saved_slots.append(slot.save())
	return {
		"capacity": capacity,
		"slots": saved_slots,
	}

func load(data: Dictionary, item_database: Dictionary = {}) -> void:
	clear()
	capacity = int(data.get("capacity", capacity))
	var saved_slots: Array = data.get("slots", [])
	for saved_slot: Dictionary in saved_slots:
		var item_id: String = str(saved_slot.get("item_id", ""))
		if item_database.has(item_id):
			add_item(item_database[item_id], int(saved_slot.get("amount", 1)))

func _find_slot(item_id: String) -> StudioInventorySlot:
	for slot: StudioInventorySlot in slots:
		if slot.item != null and slot.item.id == item_id:
			return slot
	return null
