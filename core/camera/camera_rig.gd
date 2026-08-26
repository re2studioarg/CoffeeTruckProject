class_name CameraRig
extends Node3D
## Cámara ortográfica de diorama con rotación direccional fija.
## Q siempre gira a la DERECHA (+180°), E siempre gira a la IZQUIERDA (-180°).
## Como cada giro es de media vuelta, dos Q = 360°, dos E = 360° (en sentido opuesto).
## El jugador solo puede estar en dos vistas (un costado u otro), sin rotación libre.
## Mantiene zoom con rueda del mouse y ángulo de inclinación (tilt) configurable.

## Ángulo inicial (rotación en Y, grados) de la vista por defecto
@export var start_angle: float = 90.0
## Duración de la animación de giro (segundos)
@export var snap_duration: float = 0.5
## Ángulo de inclinación respecto a la horizontal (grados). 0=horizontal, 90=cenital.
@export var tilt_angle: float = 55.0

## Tamaño ortográfico mínimo (más zoom in)
@export var min_zoom: float = 2.0
## Tamaño ortográfico máximo (más zoom out)
@export var max_zoom: float = 15.0
## Velocidad de zoom
@export var zoom_speed: float = 1.5
## Zoom inicial
@export var default_zoom: float = 7.0

## Si está habilitada la rotación direccional con Q/E
@export var rotation_enabled: bool = true

@onready var camera: Camera3D = $Camera3D

var _current_zoom: float
var _target_angle: float = 90.0
var _turn_tween: Tween


func _ready() -> void:
	_current_zoom = default_zoom

	# Configurar cámara ortográfica
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = _current_zoom

	# Posicionar la cámara según el tilt (ángulo cenital)
	_update_camera_position()

	# Fijar el ángulo inicial (continuo, sin wrap para permitir giros de 360°+)
	_target_angle = start_angle
	rotation_degrees.y = start_angle

	print("CameraRig lista | Q=derecha(+180°) E=izquierda(-180°) | Zoom: Scroll | Tilt: ", tilt_angle, "°")


func _process(_delta: float) -> void:
	_handle_zoom()
	_update_wall_visibility()


## Oculta la pared que queda enfrente de la cámara (la "pared cercana"),
## dejando visibles las demás para poder ver el interior del truck.
## Solo oculta paredes con can_be_hidden = true (las frontales/traseras quedan fijas).
## Requiere que las paredes estén en el grupo "truck_wall" con su dirección
## exterior declarada en outward_normal (script TruckWall).
func _update_wall_visibility() -> void:
	var walls: Array[Node] = get_tree().get_nodes_in_group("truck_wall")
	if walls.is_empty():
		return

	# Dirección horizontal desde el centro del truck hacia la cámara
	var cam_dir: Vector3 = camera.global_position
	cam_dir.y = 0.0
	cam_dir = cam_dir.normalized()

	# Encontrar la pared Ocultable cuya cara exterior apunta más hacia la cámara
	var best: TruckWall = null
	var best_dot: float = -INF
	for wall in walls:
		if wall is TruckWall and wall.can_be_hidden:
			var d: float = cam_dir.dot(wall.outward_normal)
			if d > best_dot:
				best_dot = d
				best = wall

	# Ocultar solo esa pared (si existe), mostrar el resto de las ocultables
	for wall in walls:
		if wall is TruckWall:
			if wall.can_be_hidden:
				wall.visible = (wall != best)
			else:
				wall.visible = true


func _input(event: InputEvent) -> void:
	# Q gira a la derecha (+180°), E gira a la izquierda (-180°)
	if event is InputEventKey and event.pressed and not event.echo:
		if not rotation_enabled:
			return
		if event.keycode == KEY_Q:
			_rotate_view(180.0)
		elif event.keycode == KEY_E:
			_rotate_view(-180.0)

	# Zoom con rueda del mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_current_zoom = maxf(_current_zoom - zoom_speed, min_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_current_zoom = minf(_current_zoom + zoom_speed, max_zoom)


func _handle_zoom() -> void:
	if not camera:
		return
	camera.size = lerpf(camera.size, _current_zoom, 12.0 * get_process_delta_time())


## Rota la cámara en la dirección indicada (ángulo en grados, + derecha / - izquierda)
func _rotate_view(angle_delta: float) -> void:
	if _turn_tween and _turn_tween.is_valid():
		_turn_tween.kill()

	# Acumular ángulo CONTINUO (sin wrap). Así el tween avanza siempre en la
	# misma dirección y puede completar un giro de 360° sin oscilar.
	# Ej: 90 -> 270 -> 450 -> 630 (Q/Q = dos giros a la derecha = 360°).
	_target_angle += angle_delta

	_turn_tween = create_tween()
	_turn_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_turn_tween.tween_property(self, "rotation_degrees:y", _target_angle, snap_duration)


func _update_camera_position() -> void:
	# La cámara mira al origen desde arriba con el ángulo de tilt.
	var rad: float = deg_to_rad(tilt_angle)
	var distance: float = default_zoom * 1.5
	camera.position = Vector3(0, distance * sin(rad), distance * cos(rad))
	camera.look_at(Vector3.ZERO)
