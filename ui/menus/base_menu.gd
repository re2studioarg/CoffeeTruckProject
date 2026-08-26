class_name BaseMenu
extends Control

signal opened
signal closed

func open() -> void:
	visible = true
	opened.emit()

func close() -> void:
	visible = false
	closed.emit()

func toggle() -> void:
	if visible:
		close()
	else:
		open()
