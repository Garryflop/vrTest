extends Node3D

enum VaultState { IDLE, DENIED, DECRYPTING, OPEN }

@onready var key_slot: Node                   = $Terminal/KeySlot
@onready var status_label: Label3D            = $Terminal/StatusLabel
@onready var status_light: MeshInstance3D     = $Terminal/StatusLight
@onready var door: Node3D                     = $Terminal/Door
@onready var reward: Node3D                   = $Terminal/CryptoReward
@onready var sound_denied: AudioStreamPlayer3D  = $AudioManager/SoundDenied
@onready var sound_approved: AudioStreamPlayer3D = $AudioManager/SoundApproved

@export var mat_idle: StandardMaterial3D
@export var mat_denied: StandardMaterial3D
@export var mat_approved: StandardMaterial3D

var current_state: VaultState = VaultState.IDLE

func _ready() -> void:
	reward.visible = false
	status_light.material_override = mat_idle
	status_label.text = "INSERT KEY TO AUTHENTICATE"
	key_slot.has_snapped.connect(_on_key_inserted)
	key_slot.has_unsnapped.connect(_on_key_removed)

func _on_key_removed(_obj) -> void:
	if current_state == VaultState.OPEN:
		return
	current_state = VaultState.IDLE
	status_light.material_override = mat_idle
	status_label.text = "INSERT KEY TO AUTHENTICATE"

func _on_key_inserted(key_object) -> void:
	if current_state == VaultState.OPEN:
		return
	if key_object.is_in_group("private_key"):
		_sequence_approved()
	elif key_object.is_in_group("public_key"):
		_sequence_denied("PUBLIC KEY IS NOT A SIGNATURE\nIt's your address, not a password\nUse your PRIVATE KEY")
	elif key_object.is_in_group("wrong_key"):
		_sequence_denied("WRONG PRIVATE KEY\nThis signature belongs to someone else\nOnly YOUR key can sign")
	else:
		_sequence_denied("INVALID OBJECT\nThis is not a key")

# ── DENIED ──────────────────────────────────────────────────
func _sequence_denied(reason: String) -> void:
	if current_state == VaultState.DENIED:
		return
	current_state = VaultState.DENIED
	sound_denied.play()
	status_label.text = "[!] ACCESS DENIED\n" + reason

	# Красный пульс x3
	var tween = create_tween()
	for _i in range(3):
		tween.tween_callback(func():
			status_light.material_override = mat_denied)
		tween.tween_interval(0.18)
		tween.tween_callback(func():
			status_light.material_override = mat_idle)
		tween.tween_interval(0.18)

	# Выбросить ключ через 1.5 сек
	await get_tree().create_timer(1.5).timeout
	if key_slot.has_method("drop_object"):
		key_slot.drop_object()
	current_state = VaultState.IDLE
	status_label.text = "INSERT KEY TO AUTHENTICATE"
	status_light.material_override = mat_idle

# ── APPROVED ─────────────────────────────────────────────────
func _sequence_approved() -> void:
	current_state = VaultState.DECRYPTING
	sound_approved.play()
	status_light.material_override = mat_approved
	await _animate_decrypting()
	_open_door()
	await get_tree().create_timer(0.9).timeout
	reward.visible = true
	status_label.text = "[✓] VAULT OPEN\nTake your crypto asset"
	current_state = VaultState.OPEN

func _animate_decrypting() -> void:
	var steps := [
		"[✓] PRIVATE KEY VERIFIED",
		"[✓] PRIVATE KEY VERIFIED\nCHECKING SIGNATURE.",
		"[✓] PRIVATE KEY VERIFIED\nCHECKING SIGNATURE..",
		"[✓] PRIVATE KEY VERIFIED\nCHECKING SIGNATURE...",
		"[✓] SIGNATURE VALID\nDECRYPTING VAULT.",
		"[✓] SIGNATURE VALID\nDECRYPTING VAULT..",
		"[✓] SIGNATURE VALID\nDECRYPTING VAULT...",
	]
	for step in steps:
		status_label.text = step
		await get_tree().create_timer(0.35).timeout

func _open_door() -> void:
	var tween = create_tween()
	tween.tween_property(door, "rotation_degrees:y", -110.0, 1.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
