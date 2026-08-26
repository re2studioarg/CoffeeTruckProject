class_name SceneManagerService
extends Node

signal scene_change_started(scene_path: String)
signal scene_change_finished(scene_path: String)
signal scene_change_failed(scene_path: String, error: Error)

var current_scene_path: String = ""
var previous_scene_path: String = ""

func change_scene(scene_path: String) -> Error:
	if scene_path.strip_edges().is_empty():
		scene_change_failed.emit(scene_path, ERR_INVALID_PARAMETER)
		return ERR_INVALID_PARAMETER
	scene_change_started.emit(scene_path)
	previous_scene_path = current_scene_path
	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		scene_change_failed.emit(scene_path, error)
		return error
	current_scene_path = scene_path
	scene_change_finished.emit(scene_path)
	return OK

func reload_scene() -> Error:
	var error: Error = get_tree().reload_current_scene()
	if error != OK:
		scene_change_failed.emit(current_scene_path, error)
	return error

func load_level(level_data: LevelData) -> Error:
	if level_data == null:
		return ERR_INVALID_PARAMETER
	return change_scene(level_data.scene_path)

func back_to_previous_scene() -> Error:
	if previous_scene_path.is_empty():
		return ERR_DOES_NOT_EXIST
	return change_scene(previous_scene_path)
