extends Node3D

signal action_triggered(action: String)

func _ready() -> void:
	$StatusLabel.text = tr("ROOM_1_MAIN_BOARD_TEXT")

func set_status(text: String):
	$StatusLabel.text = tr("ROOM_1_MAIN_BOARD_TEXT") + "\n" + text

func set_button_text(action_name: String, text: String):
	if action_name == "send_decent":
		$BtnDecent/Label3D.text = text
	elif action_name == "send_cent":
		$BtnCent/Label3D.text = text

# Called by the board_button.gd when clicked via RayCast or XR pointer
func click_action(action_name: String):
	action_triggered.emit(action_name)
