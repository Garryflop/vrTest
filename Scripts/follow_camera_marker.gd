extends Marker3D

@export var rotation_speed: float = 5.0
@onready var camera = get_viewport().get_camera_3d()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = camera.global_position
	rotation.y = lerp(rotation.y, camera.rotation.y, rotation_speed * delta)
