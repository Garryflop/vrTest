extends Control

const CFG_PATH = "user://settings.cfg"
var cfg := ConfigFile.new()

@onready var music_slider    = $MarginContainer/VBoxContainer/Audio/Music/MusicSlider
@onready var sfx_slider      = $MarginContainer/VBoxContainer/Audio/SFX/SfxSlider
#@onready var brightness_sl   = $MarginContainer/VBoxContainer/Display/bright/BrSlider
#@onready var vignette_check  = $"MarginContainer/VBoxContainer/VR comf/VR3/CheckBox"
#@onready var vignette_sl     = $"MarginContainer/VBoxContainer/VR comf/VR2/VignSlider"
@onready var env             = preload("res://Assets/materials/lobby_env.tres")

func _ready():
	cfg.load(CFG_PATH)
	music_slider.value   = cfg.get_value("audio",   "music",      0.8)
	sfx_slider.value     = cfg.get_value("audio",   "sfx",        1.0)
	#brightness_sl.value  = cfg.get_value("display", "brightness", 0.5)
	#vignette_check.button_pressed = cfg.get_value("vr", "vignette", true)
	#vignette_sl.value    = cfg.get_value("vr",      "vignette_amount", 0.4)
	#
	## слайдер активен только когда виньетка включена
	#vignette_sl.editable = vignette_check.button_pressed
	
	_apply_all()

func _on_vignette_check_toggled(on: bool):
	#vignette_sl.editable = on
	_apply_vignette()

func _apply_all():
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_slider.value))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_slider.value))
	#env.adjustment_brightness = brightness_sl.value + 0.5
	_apply_vignette()

func _apply_vignette():
	pass
	# передаёшь в свой шейдер виньетки
	#var strength = vignette_sl.value if vignette_check.button_pressed else 0.0
	#RenderingServer.global_shader_parameter_set("vignette_strength", strength)

func _on_save_pressed():
	cfg.set_value("audio",   "music",           music_slider.value)
	cfg.set_value("audio",   "sfx",             sfx_slider.value)
	#cfg.set_value("display", "brightness",      brightness_sl.value)
	#cfg.set_value("vr",      "vignette",        vignette_check.button_pressed)
	#cfg.set_value("vr",      "vignette_amount", vignette_sl.value)
	cfg.save(CFG_PATH)
	_apply_all()


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1,value)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2,value)
