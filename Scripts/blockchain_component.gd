extends Node3D

@onready var cube: XRToolsPickable = %Cube
@onready var cube_mesh: MeshInstance3D = %MeshInstance3D

@onready var connect_object_anchor: Marker3D = %ConnectObjectAnchor
@onready var connect_object_snap_zone_anchor: Marker3D = %ConnectObjectSnapZoneAnchor

@export var input_number: int = 1
@export var output_number: int = 1

@export var input_scene: PackedScene
@export var output_scene: PackedScene

enum state {
	default,
	right,
	wrong
}
var current_state: state = state.default : set = _set_state

func _set_state(new_state: state):
	current_state = new_state
	match current_state:
		state.default:
			color = Color(0,1,1)
		state.right:
			color = Color(0,1,0)
			enable_snap_zones()
			enable_pickables()
		state.wrong:
			color = Color(1,0,0)
			reset_blockchain()

var color: Color : set = _set_color

func _set_color(new_color: Color):
	color = new_color
	cube_mesh.get_surface_override_material(0).albedo_color = color

var z_range: float = 0.1
#var held_object:PhysicsBody3D
var unique_id: String

var input_objects := []
var output_objects := []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unique_id = str(get_instance_id())
	Signals.PlaySound.connect(_right)
	Signals.ToggleMusic.connect(_wrong)
	
	
	setup_connectors(input_number, true)
	setup_connectors(output_number, false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_connectors(count: int, is_input: bool):
	if count <= 0:
		return
	# Calculate spacing so they are centered
	# If count is 1, offset is 0. If count > 1, spread them.
	for i in range(count):
		var instance = input_scene.instantiate() if is_input else output_scene.instantiate()
		
		if is_input:
			input_objects.append(instance)
			instance.add_collision_exception_with(cube)
			instance.add_to_group(unique_id)
		else:
			output_objects.append(instance)
			instance.snap_exclude = unique_id
		# Position Logic
		var x_pos = connect_object_anchor.position.x if is_input else connect_object_snap_zone_anchor.position.x
		var z_pos = 0
		
		if count > 1:
			z_pos = -0.05 + (float(i) / (count - 1)) * z_range
		instance.position = Vector3(x_pos, 0, z_pos)
		add_child(instance)

func enable_snap_zones() -> void:
	for snap_zone in output_objects:
		snap_zone.enabled = true

func enable_pickables() -> void:
	for pickable in input_objects:
		pickable.enabled = true

func reset_blockchain() -> void:
	for snap_zone in output_objects:
		if snap_zone.has_method("drop_object"):
			snap_zone.drop_object()
			snap_zone.enabled = false
	for pickable in input_objects:
		if pickable.has_method("drop"):
			pickable.drop()
			pickable.enabled = false

func _right() -> void:
	current_state = state.right

func _wrong() -> void:
	current_state = state.wrong

func _on_toggle_state() -> void:
	if current_state == state.right or current_state == state.default:
		current_state = state.wrong
	elif current_state == state.wrong:
		current_state = state.right


func _on_d_button_button_pressed() -> void:
	_on_toggle_state()
