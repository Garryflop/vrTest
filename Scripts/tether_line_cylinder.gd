extends Node3D

var thickness: int = 1
var cube: XRToolsPickable
var connect_object: XRToolsPickable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if connect_object.is_picked_up():
		scale = Vector3(0.01 * thickness, (cube.position.distance_to(connect_object.position))/2, 0.01 * thickness)
		look_at_from_position(cube.position,connect_object.position)
		rotation.x += deg_to_rad(90)
		global_transform.origin = (cube.global_transform.origin + connect_object.global_transform.origin) / 2
	else:
		scale = Vector3(0,0,0)
