extends Control




func _on_play_sound_button_pressed() -> void:
	Signals.PlaySound.emit()


func _on_toggle_music_button_pressed() -> void:
	Signals.ToggleMusic.emit()
