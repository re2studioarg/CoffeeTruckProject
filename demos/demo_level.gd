class_name FrameworkDemoLevel
extends Control

@export var level_name: String = "Level"
@export_file("*.tscn") var next_scene_path: String = ""
@export_file("*.tscn") var home_scene_path: String = "res://demos/framework_demo.tscn"

var status_label: Label
var scene_manager: Node

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	scene_manager = get_node_or_null("/root/SceneManager")
	_create_ui()
	if scene_manager != null:
		scene_manager.set("current_scene_path", scene_file_path)

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
	title.text = "SceneManager Demo - %s" % level_name
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	status_label = Label.new()
	status_label.text = "Esta escena fue cargada con SceneManager.change_scene()."
	root.add_child(status_label)

	var buttons: HBoxContainer = HBoxContainer.new()
	root.add_child(buttons)
	buttons.add_child(_make_button("Cambiar a siguiente escena", _on_next_pressed))
	buttons.add_child(_make_button("Recargar escena", _on_reload_pressed))
	buttons.add_child(_make_button("Volver al demo principal", _on_home_pressed))

func _make_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	return button

func _on_next_pressed() -> void:
	if next_scene_path.is_empty():
		status_label.text = "No hay next_scene_path configurado."
		return
	var error: Error = scene_manager.call("change_scene", next_scene_path)
	status_label.text = "SceneManager.change_scene('%s') -> %s" % [next_scene_path, error]

func _on_reload_pressed() -> void:
	var error: Error = scene_manager.call("reload_scene")
	status_label.text = "SceneManager.reload_scene() -> %s" % error

func _on_home_pressed() -> void:
	var error: Error = scene_manager.call("change_scene", home_scene_path)
	status_label.text = "SceneManager.change_scene('%s') -> %s" % [home_scene_path, error]
