extends MeshInstance3D

var thickness: int = 1
var cube: XRToolsPickable
@onready var connect_object: RigidBody3D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cube = get_parent().get_parent()

func _physics_process(delta: float) -> void:
	scale = Vector3(0.01 * thickness, (cube.position.distance_to(connect_object.position))/2, 0.01 * thickness)
	look_at_from_position(cube.position,connect_object.position)
	rotation.x += deg_to_rad(90)
	position = (cube.position + connect_object.position) / 2
