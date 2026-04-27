@tool
extends XRToolsPickable

var blockchain_component: Node3D
var z_offset: float
@export var tether_scene: PackedScene

func _ready():
	blockchain_component = get_parent()
	z_offset = position.z
	var instance = tether_scene.instantiate()
	instance.connect_object = self
	instance.cube = blockchain_component.cube
	add_sibling(instance)
	super()

func _physics_process(delta: float) -> void:
	if blockchain_component:
		if !is_picked_up():
			global_transform = blockchain_component.connect_object_anchor.global_transform
			global_transform.origin += global_transform.basis.z * z_offset
