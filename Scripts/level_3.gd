@tool
extends XRToolsSceneBase

@onready var terminal: StaticBody3D = $Terminal
@onready var private_key_box: Node3D = $PrivateKeyBox

@export_file('*.tscn') var next_level_scene : String

var can_reset: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Signals.ConfirmNextLevel.connect(_on_confirm_next_level)

func _on_reset_button_button_pressed() -> void:
	if can_reset:
		terminal.reset()
		private_key_box.reset()
		Signals.LevelReset.emit()


func _on_terminal_door_opened() -> void:
	can_reset = true


func _on_terminal_door_opening() -> void:
	can_reset = false

func _on_confirm_next_level() -> void:
	load_scene(next_level_scene)
