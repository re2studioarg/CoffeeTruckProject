class_name GameService
extends Node

signal pause_changed(paused: bool)

var is_paused: bool = false
var save_providers: Array[Node] = []

func set_paused(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	pause_changed.emit(paused)

func toggle_pause() -> void:
	set_paused(not is_paused)

func register_save_provider(provider: Node) -> void:
	if provider != null and not save_providers.has(provider):
		save_providers.append(provider)

func unregister_save_provider(provider: Node) -> void:
	save_providers.erase(provider)

func collect_save_data() -> Dictionary:
	var data: Dictionary = {}
	for provider: Node in save_providers:
		if provider != null and provider.has_method("save"):
			data[str(provider.get_path())] = provider.call("save")
	return data

func apply_save_data(data: Dictionary) -> void:
	for provider: Node in save_providers:
		if provider == null:
			continue
		var provider_path: String = str(provider.get_path())
		if provider.has_method("load") and data.has(provider_path):
			provider.call("load", data[provider_path])
