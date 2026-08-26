class_name SettingsManagerService
extends Node

const SETTINGS_PATH = "user://settings.cfg"

signal setting_changed(section: String, key: String, value: Variant)
signal settings_loaded
signal settings_saved

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	load_settings()

func set_value(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	setting_changed.emit(section, key, value)

func get_value(section: String, key: String, default_value: Variant = null) -> Variant:
	return config.get_value(section, key, default_value)

func save_settings() -> Error:
	var error: Error = config.save(SETTINGS_PATH)
	if error == OK:
		settings_saved.emit()
	return error

func load_settings() -> Error:
	var error: Error = config.load(SETTINGS_PATH)
	settings_loaded.emit()
	return error
