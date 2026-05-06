@tool
extends XRToolsViewport2DIn3D
class_name Button3D

signal button_pressed

@onready var static_body: StaticBody3D = %StaticBody3D
@onready var monitor: Node3D = %MonitorV2
@onready var screen: MeshInstance3D = %Screen

@export var screen_visible: bool = true

func _ready():
	# Wait a frame to ensure the scene inside the viewport is loaded
	super()
	
	# Find the button inside the 2D scene
	# This assumes your 2D scene has a Button node
	var btn = get_scene_instance().find_child("Button", true, false)
	
	if btn:
		# Connect the 2D button signal to a local function
		btn.connect("pressed", _on_inner_button_pressed)
	
	if !screen_visible:
		monitor.hide()
		screen.hide()

func _on_inner_button_pressed() -> void:
	button_pressed.emit()
	
	
