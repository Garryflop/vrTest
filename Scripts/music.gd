extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.ToggleMusic.connect(_on_toggle_music)

func _on_toggle_music() -> void:
	playing = !playing
