@tool
extends XRToolsSceneBase

@onready var terminal: StaticBody3D = $Terminal
@onready var private_key_box: Node3D = $PrivateKeyBox

var can_reset: bool = true

func _on_reset_button_button_pressed() -> void:
	if can_reset:
		terminal.reset()
		private_key_box.reset()


func _on_terminal_door_opened() -> void:
	can_reset = true


func _on_terminal_door_opening() -> void:
	can_reset = false
