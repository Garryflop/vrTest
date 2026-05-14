@tool
extends XRToolsSceneBase

@export_file('*.tscn') var game_scene : String
@onready var panel_credits:Node3D = $panel_credits
@onready var panel_settings: Node3D = $panel_settings
@onready var panel_play: Node3D = $panel_play

@onready var audio_tutor_system: Node3D = $AudioTutorSystem
@onready var audio_tutor_system_2: Node3D = $AudioTutorSystem2


func _ready() -> void:
	if Globals.is_completed_game:
		audio_tutor_system.hide()
		audio_tutor_system_2.show()
	
	var y_ex: float = 0.7
	panel_play.position     = Vector3(0.0,y_ex,-1.3)
	panel_settings.position = Vector3(-1.35, y_ex, -0.7)
	panel_credits.position  = Vector3(1.35, y_ex, -0.7)

	panel_settings.rotation_degrees.y =  45.0
	panel_credits.rotation_degrees.y  = -45.0

	# Play панель — главная, всегда яркая
	panel_play.is_main = true

	_animate_in(panel_play,     0.0)
	_animate_in(panel_settings, 0.15)
	_animate_in(panel_credits,  0.30)
	Signals.PlayButton.connect(_on_play_button_pressed)
	Signals.CreditsButton.connect(_on_credits_button_pressed)
	Signals.QuitButton.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	load_scene(game_scene)

func _on_credits_button_pressed() -> void:
	print("Pepe")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _animate_in(panel: Node3D, delay: float):
	panel.scale = Vector3.ZERO
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(delay)
	tween.tween_property(panel, "scale", Vector3.ONE, 0.4)
