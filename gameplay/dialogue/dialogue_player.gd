class_name DialoguePlayer
extends Node

signal dialogue_started(dialogue: DialogueData)
signal dialogue_advanced(entry: DialogueEntry)
signal option_selected(option: DialogueOption)
signal dialogue_finished(dialogue: DialogueData)

var current_dialogue: DialogueData
var current_index: int = -1

func start_dialogue(dialogue: DialogueData) -> void:
	if dialogue == null or dialogue.entries.is_empty():
		return
	current_dialogue = dialogue
	current_index = 0
	dialogue_started.emit(dialogue)
	_emit_current_entry()

func advance() -> void:
	if current_dialogue == null:
		return
	var entry: DialogueEntry = current_dialogue.entries[current_index]
	if not entry.options.is_empty():
		return
	current_index += 1
	if current_index >= current_dialogue.entries.size():
		finish_dialogue()
		return
	_emit_current_entry()

func choose_option(option_index: int) -> void:
	if current_dialogue == null:
		return
	var entry: DialogueEntry = current_dialogue.entries[current_index]
	if option_index < 0 or option_index >= entry.options.size():
		return
	var option: DialogueOption = entry.options[option_index]
	option_selected.emit(option)
	if option.next_index >= 0 and option.next_index < current_dialogue.entries.size():
		current_index = option.next_index
		_emit_current_entry()
	else:
		finish_dialogue()

func finish_dialogue() -> void:
	if current_dialogue == null:
		return
	var finished_dialogue: DialogueData = current_dialogue
	current_dialogue = null
	current_index = -1
	dialogue_finished.emit(finished_dialogue)

func get_current_entry() -> DialogueEntry:
	if current_dialogue == null or current_index < 0:
		return null
	return current_dialogue.entries[current_index]

func _emit_current_entry() -> void:
	var entry: DialogueEntry = get_current_entry()
	if entry != null:
		dialogue_advanced.emit(entry)
