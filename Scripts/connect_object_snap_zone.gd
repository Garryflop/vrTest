@tool
extends XRToolsSnapZone

var blockchain_component: Node3D
var z_offset: float

func _ready():
	blockchain_component = get_parent()
	z_offset = position.z
	super()

func _physics_process(delta: float) -> void:
	if blockchain_component:
		global_transform = blockchain_component.connect_object_snap_zone_anchor.global_transform
		global_transform.origin += global_transform.basis.z * z_offset
