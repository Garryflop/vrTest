extends Marker3D

@export var rotation_speed: float = 5.0
@onready var camera = get_viewport().get_camera_3d()
@export var ui:XRToolsViewport2DIn3D
@export var distance: float = -2.0
@export var scroll_distance: float = 0.2
@export var min_distance: float = -0.5
@export var max_distance: float = -4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.PlaySound.connect(_test)
	Signals.ToggleMusic.connect(_test_2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	distance = clampf(distance,max_distance,min_distance)
	ui.position.z = lerp(ui.position.z, distance, 5.0 * delta) 
	global_position = camera.global_position
	rotation.y = lerp(rotation.y, camera.rotation.y, rotation_speed * delta)

func _test() -> void:
	distance += scroll_distance
	

func _test_2() -> void:
	distance -= scroll_distance
