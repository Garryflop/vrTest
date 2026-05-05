extends Area3D
class_name NetworkNode

signal state_changed(is_on: bool)

@export var node_id: String = "node_1"
@export var is_on: bool = true

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var material_on: StandardMaterial3D
var material_off: StandardMaterial3D

func _ready() -> void:
    # Setup materials
    material_on = StandardMaterial3D.new()
    material_on.albedo_color = Color(0, 1, 0) # Green
    
    material_off = StandardMaterial3D.new()
    material_off.albedo_color = Color(1, 0, 0) # Red
    
    update_visuals()
    
    # Register with manager
    if NetworkManager:
        NetworkManager.register_node(node_id, self)
        
func toggle() -> void:
    set_state(not is_on)
    
func reset() -> void:
    set_state(true)
    
func set_state(state: bool) -> void:
    if is_on != state:
        is_on = state
        update_visuals()
        state_changed.emit(is_on)

func update_visuals() -> void:
    if not mesh_instance:
        return
        
    if is_on:
        mesh_instance.set_surface_override_material(0, material_on)
    else:
        mesh_instance.set_surface_override_material(0, material_off)

# Requires XRTools function pointer to send this signal (custom FPS Player)
func _on_xr_pointer_pressed(_at_position) -> void:
    toggle()

# Standard Godot XR Tools interaction
func pointer_event(event) -> void:
    if event.event_type == 2: # Type.PRESSED
        toggle()
