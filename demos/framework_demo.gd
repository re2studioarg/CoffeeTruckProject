class_name FrameworkDemoScene
extends Control

const SAVE_SLOT = "framework_demo"
const LEVEL_A_SCENE = "res://demos/scene_manager_level_a.tscn"

@onready var inventory: InventoryComponent = $Systems/Inventory
@onready var dialogue_player: DialoguePlayer = $Systems/DialoguePlayer

var potion: ItemData
var item_database: Dictionary = {}
var dialogue: DialogueData
var save_manager: Node
var scene_manager: Node
var inventory_label: Label
var dialogue_label: Label
var save_label: Label
var scene_label: Label
var log_label: RichTextLabel

func _ready() -> void:
	_set_full_rect()
	save_manager = get_node_or_null("/root/SaveManager")
	scene_manager = get_node_or_null("/root/SceneManager")
	_create_demo_data()
	_create_ui()
	_connect_systems()
	_log("Demo cargada. Usa los botones para probar cada sistema.")
	_refresh_inventory_label()

func _set_full_rect() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0

func _create_demo_data() -> void:
	potion = ItemData.new()
	potion.id = "potion"
	potion.display_name = "Potion"
	potion.description = "Restaura una pequeña cantidad de vida."
	potion.stackable = true
	potion.max_stack = 99
	potion.price = 10
	item_database[potion.id] = potion

	var entry_intro: DialogueEntry = DialogueEntry.new()
	entry_intro.speaker = "Narrador"
	entry_intro.text = "Este es un DialoguePlayer reutilizable. Pulsa Avanzar para continuar."

	var entry_choice: DialogueEntry = DialogueEntry.new()
	entry_choice.speaker = "NPC"
	entry_choice.text = "¿Quieres probar una opción de diálogo?"
	var option_inventory: DialogueOption = DialogueOption.new()
	option_inventory.text = "Sí, dame una poción"
	option_inventory.next_index = 2
	option_inventory.event_id = "give_potion"
	var option_finish: DialogueOption = DialogueOption.new()
	option_finish.text = "No, terminar"
	option_finish.next_index = -1
	entry_choice.options = [option_inventory, option_finish]

	var entry_reward: DialogueEntry = DialogueEntry.new()
	entry_reward.speaker = "NPC"
	entry_reward.text = "Opción elegida. Ahora puedes conectar este evento con inventario, quests, etc."
	dialogue = DialogueData.new()
	dialogue.id = "demo_dialogue"
	dialogue.entries = [entry_intro, entry_choice, entry_reward]

func _connect_systems() -> void:
	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_on_item_removed)
	inventory.inventory_changed.connect(_refresh_inventory_label)
	dialogue_player.dialogue_started.connect(_on_dialogue_started)
	dialogue_player.dialogue_advanced.connect(_on_dialogue_advanced)
	dialogue_player.option_selected.connect(_on_option_selected)
	dialogue_player.dialogue_finished.connect(_on_dialogue_finished)
	if save_manager != null:
		save_manager.connect("save_completed", _on_save_completed)
		save_manager.connect("load_completed", _on_load_completed)
		save_manager.connect("save_deleted", _on_save_deleted)
	if scene_manager != null:
		scene_manager.connect("scene_change_started", _on_scene_change_started)

func _create_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var title: Label = Label.new()
	title.text = "Studio Framework Demo"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	inventory_label = Label.new()
	root.add_child(inventory_label)
	var inventory_buttons: HBoxContainer = HBoxContainer.new()
	root.add_child(inventory_buttons)
	inventory_buttons.add_child(_make_button("Inventory: add_item()", _on_add_item_pressed))
	inventory_buttons.add_child(_make_button("Inventory: remove_item()", _on_remove_item_pressed))
	inventory_buttons.add_child(_make_button("Inventory: has_item()", _on_has_item_pressed))

	dialogue_label = Label.new()
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.text = "Dialogue: sin iniciar"
	root.add_child(dialogue_label)
	var dialogue_buttons: HBoxContainer = HBoxContainer.new()
	root.add_child(dialogue_buttons)
	dialogue_buttons.add_child(_make_button("Dialogue: start_dialogue()", _on_start_dialogue_pressed))
	dialogue_buttons.add_child(_make_button("Dialogue: advance()", _on_advance_dialogue_pressed))
	dialogue_buttons.add_child(_make_button("Dialogue: choose_option(0)", _on_choose_option_pressed))

	save_label = Label.new()
	save_label.text = "SaveManager: sin acciones todavía"
	root.add_child(save_label)
	var save_buttons: HBoxContainer = HBoxContainer.new()
	root.add_child(save_buttons)
	save_buttons.add_child(_make_button("SaveManager: save_game()", _on_save_pressed))
	save_buttons.add_child(_make_button("SaveManager: load_game()", _on_load_pressed))
	save_buttons.add_child(_make_button("SaveManager: delete_save()", _on_delete_save_pressed))

	scene_label = Label.new()
	scene_label.text = "SceneManager: pulsa el botón para cargar otra escena demo"
	root.add_child(scene_label)
	var scene_buttons: HBoxContainer = HBoxContainer.new()
	root.add_child(scene_buttons)
	scene_buttons.add_child(_make_button("SceneManager: change_scene(Level A)", _on_change_scene_pressed))

	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0.0, 180.0)
	log_label.bbcode_enabled = true
	root.add_child(log_label)

func _make_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	return button

func _on_add_item_pressed() -> void:
	var added: bool = inventory.add_item(potion, 1)
	_log("Inventory.add_item('potion', 1) -> %s" % added)

func _on_remove_item_pressed() -> void:
	var removed: bool = inventory.remove_item("potion", 1)
	_log("Inventory.remove_item('potion', 1) -> %s" % removed)

func _on_has_item_pressed() -> void:
	_log("Inventory.has_item('potion', 1) -> %s" % inventory.has_item("potion", 1))

func _on_start_dialogue_pressed() -> void:
	dialogue_player.start_dialogue(dialogue)

func _on_advance_dialogue_pressed() -> void:
	dialogue_player.advance()

func _on_choose_option_pressed() -> void:
	dialogue_player.choose_option(0)

func _on_save_pressed() -> void:
	var data: Dictionary = {
		"inventory": inventory.save(),
		"demo_note": "Guardado desde FrameworkDemoScene",
	}
	var saved: bool = bool(save_manager.call("save_game", SAVE_SLOT, data))
	_log("SaveManager.save_game('%s', data) -> %s" % [SAVE_SLOT, saved])

func _on_load_pressed() -> void:
	var data: Dictionary = save_manager.call("load_game", SAVE_SLOT)
	if data.is_empty():
		save_label.text = "SaveManager: no hay datos para cargar"
		_log("SaveManager.load_game('%s') -> {}" % SAVE_SLOT)
		return
	var inventory_data: Dictionary = data.get("inventory", {})
	inventory.load(inventory_data, item_database)
	save_label.text = "SaveManager: partida cargada desde slot '%s'" % SAVE_SLOT
	_log("SaveManager.load_game('%s') -> %s" % [SAVE_SLOT, data])

func _on_delete_save_pressed() -> void:
	var deleted: bool = bool(save_manager.call("delete_save", SAVE_SLOT))
	save_label.text = "SaveManager: delete_save('%s') -> %s" % [SAVE_SLOT, deleted]
	_log(save_label.text)

func _on_change_scene_pressed() -> void:
	var error: Error = scene_manager.call("change_scene", LEVEL_A_SCENE)
	_log("SceneManager.change_scene('%s') -> %s" % [LEVEL_A_SCENE, error])

func _on_item_added(item: ItemData, amount: int) -> void:
	_log("Signal Inventory.item_added: %s x%d" % [item.display_name, amount])

func _on_item_removed(item: ItemData, amount: int) -> void:
	_log("Signal Inventory.item_removed: %s x%d" % [item.display_name, amount])

func _on_dialogue_started(started_dialogue: DialogueData) -> void:
	_log("Signal Dialogue.dialogue_started: %s" % started_dialogue.id)

func _on_dialogue_advanced(entry: DialogueEntry) -> void:
	var options_text: String = ""
	for index: int in entry.options.size():
		var option: DialogueOption = entry.options[index]
		options_text += "\n  [%d] %s" % [index, option.text]
	dialogue_label.text = "Dialogue: %s: %s%s" % [entry.speaker, entry.text, options_text]
	_log("Signal Dialogue.dialogue_advanced: %s" % entry.text)

func _on_option_selected(option: DialogueOption) -> void:
	_log("Signal Dialogue.option_selected: %s / event_id=%s" % [option.text, option.event_id])
	if option.event_id == "give_potion":
		inventory.add_item(potion, 1)

func _on_dialogue_finished(finished_dialogue: DialogueData) -> void:
	dialogue_label.text = "Dialogue: finalizado"
	_log("Signal Dialogue.dialogue_finished: %s" % finished_dialogue.id)

func _on_save_completed(slot: String, _data: Dictionary) -> void:
	save_label.text = "SaveManager: guardado completado en slot '%s'" % slot

func _on_load_completed(slot: String, _data: Dictionary) -> void:
	save_label.text = "SaveManager: load_completed slot '%s'" % slot

func _on_save_deleted(slot: String) -> void:
	_log("Signal SaveManager.save_deleted: %s" % slot)

func _on_scene_change_started(scene_path: String) -> void:
	scene_label.text = "SceneManager: cambiando a %s" % scene_path

func _refresh_inventory_label() -> void:
	if inventory_label == null:
		return
	inventory_label.text = "Inventory: potion amount = %d | slots = %d" % [inventory.get_amount("potion"), inventory.slots.size()]

func _log(message: String) -> void:
	print(message)
	if log_label == null:
		return
	log_label.append_text("• %s\n" % message)
