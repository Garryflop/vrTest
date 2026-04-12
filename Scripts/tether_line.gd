extends MeshInstance3D

@onready var start_point: XRToolsPickable = %Cube
@onready var end_point: XRToolsPickable = %ConnectObject




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not(start_point) or not(end_point):
		return
	
	mesh.clear_surfaces()
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var local_start = to_local(start_point.global_position)
	var local_end = to_local(end_point.global_position)
	
	mesh.surface_add_vertex(local_start)
	mesh.surface_add_vertex(local_end)
	
	mesh.surface_end()
