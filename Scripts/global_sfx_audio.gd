extends AudioStreamPlayer

@export var error_sound: AudioStream
@export var success_sound: AudioStream
@export var reset_sound: AudioStream

func _ready() -> void:
	Signals.LevelError.connect(_on_level_error)
	Signals.LevelSuccess.connect(_on_level_success)
	Signals.LevelReset.connect(_on_level_reset)

func _on_level_error() -> void:
	stream = error_sound
	play()

func _on_level_success() -> void:
	stream = success_sound
	play()

func _on_level_reset() -> void:
	stream = reset_sound
	play()
