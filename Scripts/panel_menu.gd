extends Node3D

@export var dim_color    := Color(0.4, 0.4, 0.4)
@export var bright_color := Color(1.0, 1.0, 1.0)
@export var is_main      := false

# берём первого дочернего XRToolsViewport2Din3D независимо от имени
@onready var viewport_node = get_child(0)
@onready var mesh: MeshInstance3D = viewport_node.get_node("Screen")

func _ready():
	if is_main:
		_set_brightness(bright_color)
	else:
		_set_brightness(dim_color)

	viewport_node.get_node("StaticBody3D").connect(
		"pointer_event", _on_pointer_event)

func _on_pointer_event(event):
	if event.event_type == XRToolsPointerEvent.Type.ENTERED:
		_on_pointer_entered()
	elif event.event_type == XRToolsPointerEvent.Type.EXITED:
		_on_pointer_exited()

func _set_brightness(color: Color):
	var mat = mesh.get_surface_override_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
		mesh.set_surface_override_material(0, mat)
	mat.albedo_color = color

func _on_pointer_entered():
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_brightness, dim_color, bright_color, 0.15)

func _on_pointer_exited():
	if is_main: return
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_method(_set_brightness, bright_color, dim_color, 0.25)
