class_name CharacterController2D
extends CharacterBody2D

@export var speed: float = 240.0
@export var acceleration: float = 1200.0
@export var friction: float = 1400.0

var input_vector: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	input_vector = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	var target_velocity: Vector2 = input_vector * speed
	var rate: float = acceleration if input_vector.length() > 0.0 else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()
