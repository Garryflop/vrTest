extends Node3D

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var speaker_button: Node = $TutorPanel/SpeakerButton
@onready var title_label: Label3D = $TutorPanel/TitleLabel
@onready var content_label: Label3D = $TutorPanel/ContentLabel

# Назначить в инспекторе — .mp3 файл для этой сцены
@export var audio_clip: AudioStream
@export var scene_title: String = ""
@export var scene_content: String = ""

var is_playing: bool = false

func _ready() -> void:
	speaker_button.button_pressed.connect(_on_speaker_pressed)
	audio_player.finished.connect(_on_audio_finished)
	
	#title_label.text = scene_title
	#content_label.text = scene_content
	
	_update_button_label()

func _on_speaker_pressed() -> void:
	if is_playing:
		# Стоп — нажали повторно
		audio_player.stop()
		is_playing = false
	else:
		# Старт
		if audio_clip:
			audio_player.stream = audio_clip
			audio_player.play()
			is_playing = true
	_update_button_label()

func _on_audio_finished() -> void:
	is_playing = false
	_update_button_label()

func _update_button_label() -> void:
	# Визуальная индикация на кнопке
	var label = speaker_button.get_node_or_null("Label3D")
	if label:
		label.text = "⏹ STOP" if is_playing else "▶ PLAY"

func stop_audio() -> void:
	if is_playing:
		audio_player.stop()
		is_playing = false
		_update_button_label()
