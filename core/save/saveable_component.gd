class_name SaveableComponent
extends Node

signal save_requested
signal load_requested(data: Dictionary)

func save() -> Dictionary:
	return {}

func load(_data: Dictionary) -> void:
	pass
