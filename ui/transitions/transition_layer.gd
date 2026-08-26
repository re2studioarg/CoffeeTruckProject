class_name TransitionLayer
extends CanvasLayer

signal fade_out_finished
signal fade_in_finished

@export var fade_duration: float = 0.25

var color_rect: ColorRect

func _ready() -> void:
	color_rect = ColorRect.new()
	color_rect.name = "FadeRect"
	color_rect.color = Color.BLACK
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(color_rect)

func fade_out() -> void:
	await _fade_to(1.0)
	fade_out_finished.emit()

func fade_in() -> void:
	await _fade_to(0.0)
	fade_in_finished.emit()

func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", alpha, fade_duration)
	await tween.finished
