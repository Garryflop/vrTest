@tool
extends XRToolsViewport2DIn3D
class_name PlayerUI

@export var follow_speed:float = 1.0
@export var follow_marker:Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if follow_marker:
		global_transform = global_transform.interpolate_with(follow_marker.global_transform, follow_speed * delta)
	super(delta)
