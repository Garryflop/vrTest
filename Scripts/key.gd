@tool
extends XRToolsPickable

@export var public_key_highlight: StandardMaterial3D
@export var private_key_highlight: StandardMaterial3D
@export var wrong_key_highlight: StandardMaterial3D

@onready var highlight: MeshInstance3D = $Highlight

func _ready() -> void:
	super()
	if is_in_group("public_key"):
		highlight.set_surface_override_material(0,public_key_highlight)
	elif is_in_group("wrong_key"):
		highlight.set_surface_override_material(0,wrong_key_highlight)
	elif is_in_group("private_key"):
		highlight.set_surface_override_material(0,private_key_highlight)
