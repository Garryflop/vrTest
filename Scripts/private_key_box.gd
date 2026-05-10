extends Node3D

@onready var warning_label: Label3D = $WarningLabel
@onready var private_key: XRToolsPickable   = $PrivateKey
@onready var wrong_key: XRToolsPickable = $WrongKey
@onready var lid: Node3D            = $Lid
@onready var lid_snap_zone: XRToolsSnapZone = $LidSnapZone

var private_key_init_transform: Transform3D
var wrong_key_init_transform: Transform3D
var lid_init_transform: Transform3D

func _ready() -> void:
	private_key_init_transform = private_key.transform
	wrong_key_init_transform = wrong_key.transform
	lid_init_transform = lid.transform
	
	warning_label.text = "🔒 PRIVATE KEY\nNEVER SHARE THIS\nOnly you can use it"
	warning_label.modulate = Color(1, 0.4, 0.4)
	_pulse_warning()

	# Когда игрок поднял крышку — показываем предупреждение
	if lid_snap_zone.has_signal("has_dropped"):
		lid_snap_zone.has_dropped.connect(_on_lid_picked_up)
	if lid_snap_zone.has_signal("has_picked_up"):
		lid_snap_zone.has_picked_up.connect(_on_lid_dropped)
	
	private_key.visible = false
	private_key.enabled = false
	wrong_key.visible = false
	wrong_key.enabled = false

func _on_lid_picked_up() -> void:
	warning_label.text = "⚠ PRIVATE KEY EXPOSED\nDo not share this key\nwith ANYONE!"
	warning_label.modulate = Color(1, 0.1, 0.1)
	private_key.visible = true
	private_key.enabled = true
	wrong_key.visible = true
	wrong_key.enabled = true

func _on_lid_dropped(_what: Variant) -> void:
	warning_label.text = "🔒 PRIVATE KEY\nNEVER SHARE THIS\nOnly you can use it"
	warning_label.modulate = Color(1, 0.4, 0.4)

func _pulse_warning() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(warning_label, "modulate", Color(1, 0.1, 0.1), 0.9)
	tween.tween_property(warning_label, "modulate", Color(1, 0.6, 0.6), 0.9)

func reset() -> void:
	private_key.drop()
	wrong_key.drop()
	await get_tree().process_frame
	private_key.transform = private_key_init_transform
	wrong_key.transform = wrong_key_init_transform
	private_key.visible = false
	private_key.enabled = false
	wrong_key.visible = false
	wrong_key.enabled = false
	lid.transform = lid_init_transform
	lid_snap_zone.pick_up_object(lid)
	warning_label.text = "🔒 PRIVATE KEY\nNEVER SHARE THIS\nOnly you can use it"
	warning_label.modulate = Color(1, 0.4, 0.4)
	_pulse_warning()
