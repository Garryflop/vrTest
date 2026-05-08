@tool
extends XRToolsSceneBase

@export_file('*.tscn') var game_scene : String

func _ready() -> void:
	Signals.PlayButton.connect(_on_play_button_pressed)
	Signals.CreditsButton.connect(_on_credits_button_pressed)
	Signals.QuitButton.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	load_scene(game_scene)

func _on_credits_button_pressed() -> void:
	print("Pepe")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
