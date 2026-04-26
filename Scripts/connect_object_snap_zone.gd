@tool
extends XRToolsSnapZone

var home_position: Vector3
var cube: XRToolsPickable

func _ready():
	cube = get_parent()
	
	home_position = position
	super()
