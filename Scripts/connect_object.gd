@tool
extends XRToolsPickable

var home_position: Vector3
var cube: XRToolsPickable

func _ready():
	cube = get_parent().cube
	# Store where the block spawned us
	home_position = position
	super()

func _process(_delta: float) -> void:
	if !is_picked_up():
		position = home_position
