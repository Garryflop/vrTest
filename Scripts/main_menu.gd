extends Control


func _on_play_button_pressed() -> void:
	Signals.PlayButton.emit()


func _on_credits_button_pressed() -> void:
	Signals.CreditsButton.emit()


func _on_quit_button_pressed() -> void:
	Signals.QuitButton.emit()
