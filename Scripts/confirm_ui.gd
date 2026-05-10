extends Control


func _on_confirm_button_pressed() -> void:
	Signals.ConfirmNextLevel.emit()
