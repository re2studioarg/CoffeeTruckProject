class_name SaveManagerService
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"
const SAVE_VERSION = 1

signal save_completed(slot: String, data: Dictionary)
signal load_completed(slot: String, data: Dictionary)
signal save_deleted(slot: String)
signal save_failed(slot: String, reason: String)

func save_game(slot: String, data: Dictionary) -> bool:
	if slot.strip_edges().is_empty():
		save_failed.emit(slot, "Empty save slot")
		return false
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var path: String = _get_save_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		save_failed.emit(slot, "Could not open save file")
		return false
	var payload: Dictionary = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"data": data,
	}
	file.store_var(payload)
	file.close()
	save_completed.emit(slot, payload)
	return true

func load_game(slot: String) -> Dictionary:
	var path: String = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		save_failed.emit(slot, "Save file does not exist")
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		save_failed.emit(slot, "Could not read save file")
		return {}
	var payload: Variant = file.get_var()
	file.close()
	if not payload is Dictionary:
		save_failed.emit(slot, "Invalid save payload")
		return {}
	var save_data: Dictionary = payload
	load_completed.emit(slot, save_data)
	return save_data.get("data", {})

func delete_save(slot: String) -> bool:
	var path: String = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var error: Error = DirAccess.remove_absolute(path)
	if error != OK:
		save_failed.emit(slot, "Could not delete save file")
		return false
	save_deleted.emit(slot)
	return true

func has_save(slot: String) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))

func _get_save_path(slot: String) -> String:
	return SAVE_DIR + slot + SAVE_EXTENSION
