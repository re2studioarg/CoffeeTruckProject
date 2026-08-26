class_name InventoryView
extends Control

@export var inventory: InventoryComponent

func bind_inventory(new_inventory: InventoryComponent) -> void:
	if inventory != null and inventory.inventory_changed.is_connected(refresh):
		inventory.inventory_changed.disconnect(refresh)
	inventory = new_inventory
	if inventory != null:
		inventory.inventory_changed.connect(refresh)
	refresh()

func refresh() -> void:
	# Implementar en una UI concreta del juego.
	pass
