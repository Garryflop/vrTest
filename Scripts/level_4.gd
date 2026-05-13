@tool
extends XRToolsSceneBase

@onready var reset_button = $ResetButton
@onready var pow_table = $TablePoW
@onready var pos_table = $TablePoS

@export_file('*.tscn') var next_level_scene : String

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	Signals.ConfirmNextLevel.connect(_on_confirm_next_level)
	
	#reset_button.button_pressed.connect(_on_reset)

func _on_reset() -> void:
	pow_table.reset()
	pos_table.reset()

func _on_confirm_next_level() -> void:
	load_scene(next_level_scene)
