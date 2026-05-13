@tool
extends XRToolsSceneBase

@onready var reset_button = $ResetButton
@onready var pow_table = $TablePoW
@onready var pos_table = $TablePoS

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	#reset_button.button_pressed.connect(_on_reset)

func _on_reset() -> void:
	get_tree().reload_current_scene()
