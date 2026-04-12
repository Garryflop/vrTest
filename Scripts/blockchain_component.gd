extends Node3D

@onready var cube: XRToolsPickable = %Cube
@onready var connect_object: XRToolsPickable = %ConnectObject
@onready var connect_object_snap_zone: XRToolsSnapZone = %ConnectObject_snap_zone
@onready var connect_object_anchor: Marker3D = %ConnectObjectAnchor
@onready var connect_object_snap_zone_anchor: Marker3D = %ConnectObjectSnapZoneAnchor

var held_object:PhysicsBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_object.add_collision_exception_with(cube)
	
	var unique_id = str(get_instance_id())
	connect_object.add_to_group(unique_id)
	
	connect_object_snap_zone.snap_exclude = unique_id
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !connect_object.is_picked_up():
		connect_object.global_transform = connect_object_anchor.global_transform
	connect_object_snap_zone.global_transform = connect_object_snap_zone_anchor.global_transform


func _on_connect_object_snap_zone_has_picked_up(what: Variant) -> void:
	held_object = what
	held_object.add_collision_exception_with(cube)


func _on_connect_object_snap_zone_has_dropped() -> void:
	held_object.remove_collision_exception_with(cube)
	held_object = null
