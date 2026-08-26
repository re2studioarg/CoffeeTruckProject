class_name InputManagerService
extends Node

signal input_method_changed(method: StringName)

var current_input_method: StringName = &"keyboard_mouse"

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_set_input_method(&"gamepad")
	elif event is InputEventKey or event is InputEventMouse:
		_set_input_method(&"keyboard_mouse")

func is_action_pressed(action: StringName) -> bool:
	return Input.is_action_pressed(action)

func is_action_just_pressed(action: StringName) -> bool:
	return Input.is_action_just_pressed(action)

func get_move_vector(left: StringName = &"ui_left", right: StringName = &"ui_right", up: StringName = &"ui_up", down: StringName = &"ui_down") -> Vector2:
	return Input.get_vector(left, right, up, down)

func _set_input_method(method: StringName) -> void:
	if current_input_method == method:
		return
	current_input_method = method
	input_method_changed.emit(method)
