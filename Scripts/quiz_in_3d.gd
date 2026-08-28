@tool
extends XRToolsViewport2DIn3D

@export var room_id: String = "room_1"

func _ready():
	super()
	
	if Engine.is_editor_hint():
		return
	get_scene_instance().start_quiz(room_id)
	Signals.QuizCompleted.connect(_on_quiz_completed)

func _on_quiz_completed() -> void:
	hide()
