extends AudioStreamPlayer

@export var error_sound: AudioStream
@export var success_sound: AudioStream
@export var reset_sound: AudioStream
@export var quiz_complete_sound: AudioStream
@export var quiz_not_complete_sound: AudioStream

func _ready() -> void:
	Signals.LevelError.connect(_on_level_error)
	Signals.LevelSuccess.connect(_on_level_success)
	Signals.LevelReset.connect(_on_level_reset)
	Signals.PlaySound.connect(_on_play_sound)

func _on_play_sound(sound_name: String) -> void:
	if sound_name == "success":
		stream = success_sound
	elif sound_name == "error":
		stream = error_sound
	elif sound_name == "reset":
		stream = reset_sound
	elif sound_name == "quiz_complete":
		stream = quiz_complete_sound
	elif sound_name == "quiz_not_complete":
		stream = quiz_not_complete_sound
	play()

func _on_level_error() -> void:
	_on_play_sound("error")

func _on_level_success() -> void:
	_on_play_sound("success")

func _on_level_reset() -> void:
	_on_play_sound("reset")
