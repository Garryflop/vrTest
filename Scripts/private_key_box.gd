extends Node3D

@onready var warning_label: Label3D = $WarningLabel
@onready var private_key: Node3D    = $PrivateKey
@onready var lid: Node3D            = $Lid

func _ready() -> void:
	warning_label.text = "🔒 PRIVATE KEY\nNEVER SHARE THIS\nOnly you can use it"
	warning_label.modulate = Color(1, 0.4, 0.4)
	_pulse_warning()

	# Когда игрок поднял крышку — показываем предупреждение
	if lid.has_signal("picked_up"):
		lid.picked_up.connect(_on_lid_picked_up)
	if lid.has_signal("dropped"):
		lid.dropped.connect(_on_lid_dropped)

func _on_lid_picked_up() -> void:
	warning_label.text = "⚠ PRIVATE KEY EXPOSED\nDo not share this key\nwith ANYONE!"
	warning_label.modulate = Color(1, 0.1, 0.1)

func _on_lid_dropped() -> void:
	warning_label.text = "🔒 PRIVATE KEY\nNEVER SHARE THIS\nOnly you can use it"
	warning_label.modulate = Color(1, 0.4, 0.4)

func _pulse_warning() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(warning_label, "modulate", Color(1, 0.1, 0.1), 0.9)
	tween.tween_property(warning_label, "modulate", Color(1, 0.6, 0.6), 0.9)
