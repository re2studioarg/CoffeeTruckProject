class_name TruckWall
extends MeshInstance3D
## Pared del diorama del food truck.
## outward_normal indica hacia dónde apunta su cara exterior.
## La cámara usa esto para ocultar la pared que queda "enfrente" y revelar el interior.

## Dirección (normalizada) hacia la cara exterior de la pared.
## Ej: Vector3.RIGHT (1,0,0) para la pared derecha, Vector3.LEFT para la izquierda,
## Vector3.BACK (0,0,-1) para la pared trasera.
@export var outward_normal: Vector3 = Vector3.RIGHT
## Si es false, la pared NUNCA se oculta al rotar la cámara (ej: paredes frontales/traseras).
@export var can_be_hidden: bool = true


func _ready() -> void:
	# Se registra en el grupo para que CameraRig la encuentre y pueda ocultarla.
	add_to_group("truck_wall")
