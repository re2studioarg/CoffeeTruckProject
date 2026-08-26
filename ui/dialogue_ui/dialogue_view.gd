class_name DialogueView
extends Control

@export var dialogue_player: DialoguePlayer

func bind_dialogue_player(player: DialoguePlayer) -> void:
	if dialogue_player != null:
		if dialogue_player.dialogue_advanced.is_connected(_on_dialogue_advanced):
			dialogue_player.dialogue_advanced.disconnect(_on_dialogue_advanced)
		if dialogue_player.dialogue_finished.is_connected(_on_dialogue_finished):
			dialogue_player.dialogue_finished.disconnect(_on_dialogue_finished)
	dialogue_player = player
	if dialogue_player != null:
		dialogue_player.dialogue_advanced.connect(_on_dialogue_advanced)
		dialogue_player.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_advanced(entry: DialogueEntry) -> void:
	visible = true
	# Implementar render del texto/opciones en una UI concreta del juego.
	print("%s: %s" % [entry.speaker, entry.text])

func _on_dialogue_finished(_dialogue: DialogueData) -> void:
	visible = false
