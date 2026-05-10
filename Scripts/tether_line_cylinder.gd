extends Node3D

var thickness: int = 1
var cube: XRToolsPickable
var connect_object: XRToolsPickable
var is_placed: bool = false

@onready var intact_pipe: MeshInstance3D = $Intact_Pipes/Intact_Pipe

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if connect_object.is_picked_up() or is_placed:
		scale = Vector3(0.01 * thickness, (cube.global_position.distance_to(connect_object.global_position))/2, 0.01 * thickness)
		look_at_from_position(cube.global_position,connect_object.global_position)
		rotation.x += deg_to_rad(90)
		global_transform.origin = (cube.global_transform.origin + connect_object.global_transform.origin) / 2
	else:
		scale = Vector3(0,0,0)

func set_invalid(is_chain_valid: bool):
	if !is_chain_valid:
		intact_pipe.material_overlay.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
		intact_pipe.material_overlay.emission = Color(0.0, 1.0, 0.0, 1.0)
	else:
		intact_pipe.material_overlay.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
		intact_pipe.material_overlay.emission = Color(1.0, 0.0, 0.0, 1.0)
