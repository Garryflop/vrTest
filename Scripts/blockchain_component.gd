extends Node3D

@onready var cube: XRToolsPickable = %Cube

@onready var connect_object_anchor: Marker3D = %ConnectObjectAnchor
@onready var connect_object_snap_zone_anchor: Marker3D = %ConnectObjectSnapZoneAnchor

@export var input_number: int = 1
@export var output_number: int = 1

@export var input_scene: PackedScene
@export var output_scene: PackedScene

var z_range: float = 0.1
#var held_object:PhysicsBody3D
var unique_id: String

var input_objects := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unique_id = str(get_instance_id())
	
	setup_connectors(input_number, true)
	setup_connectors(output_number, false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if !connect_object.is_picked_up():
		#connect_object.global_transform = connect_object_anchor.global_transform
	#connect_object_snap_zone.global_transform = connect_object_snap_zone_anchor.global_transform
	pass

func setup_connectors(count: int, is_input: bool):
	if count <= 0:
		return
	# Calculate spacing so they are centered
	# If count is 1, offset is 0. If count > 1, spread them.
	for i in range(count):
		var instance = input_scene.instantiate() if is_input else output_scene.instantiate()
		
		if is_input:
			instance.add_collision_exception_with(cube)
			instance.add_to_group(unique_id)
		else:
			instance.snap_exclude = unique_id
		# Position Logic
		var x_pos = connect_object_anchor.position.x if is_input else connect_object_snap_zone_anchor.position.x
		var z_pos = 0
		
		if count > 1:
			z_pos = -0.05 + (float(i) / (count - 1)) * z_range
		instance.position = Vector3(x_pos, 0, z_pos)
		add_child(instance)


#func _on_connect_object_snap_zone_has_picked_up(what: Variant) -> void:
	#held_object = what
	#held_object.add_collision_exception_with(cube)
#
#
#func _on_connect_object_snap_zone_has_dropped() -> void:
	#held_object.remove_collision_exception_with(cube)
	#held_object = null
