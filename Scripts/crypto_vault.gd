extends StaticBody3D

enum VaultState { IDLE, DENIED, DECRYPTING, OPEN }

signal door_opened
signal door_opening

#@onready var key_slot: XRToolsSnapZone        = $Door/KeySlot
@onready var key_slot_right: XRToolsSnapZone = $Door/KeySlotRight
@onready var key_slot_left: XRToolsSnapZone = $Door/KeySlotLeft
@onready var status_label: Label3D            = $StatusLabel
@onready var status_light: MeshInstance3D     = $StatusLight
@onready var door: StaticBody3D               = $Door
@onready var reward: XRToolsPickable          = $Money
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#@onready var sound_denied: AudioStreamPlayer3D  = $AudioManager/SoundDenied
#@onready var sound_approved: AudioStreamPlayer3D = $AudioManager/SoundApproved

@export var mat_idle: StandardMaterial3D
@export var mat_denied: StandardMaterial3D
@export var mat_approved: StandardMaterial3D

var current_state: VaultState = VaultState.IDLE

var reward_init_transform: Transform3D 

var left_object: Variant = null
var right_object: Variant = null

func _ready() -> void:
	reward.visible = false
	reward.enabled = false
	reward_init_transform = reward.transform
	status_light.material_override = mat_idle
	status_label.text = "ВСТАВЬТЕ ВАШ ЛИЧНЫЙ И ПУБЛИЧНЫЙ КЛЮЧ 
ДЛЯ ВХОДА В КРИПТОКОШЕЛЕК"
	#key_slot.has_picked_up.connect(_on_key_inserted)
	#key_slot.has_dropped.connect(_on_key_removed)

func _on_keyslot_inserted(what: Variant, is_right: bool) -> void:
	print("Key inserted is right: ", is_right)
	if is_right:
		right_object = what
	else:
		left_object = what
	update_terminal()

func _on_keyslot_removed(is_right: bool) -> void:
	print("Key removed is right: ", is_right)
	if is_right:
		right_object = null
	else:
		left_object = null
	update_terminal()

func update_terminal() -> void:
	if current_state == VaultState.OPEN:
		return
	var keys: Array = [right_object, left_object]
	var is_wrong_key: bool = keys.any(func(node): 
		if is_instance_valid(node):
			return node.is_in_group("wrong_key")
		return false)
	var is_private_key: bool = keys.any(func(node): 
		if is_instance_valid(node):
			return node.is_in_group("private_key")
		return false)
	var is_public_key: bool = keys.any(func(node): 
		if is_instance_valid(node):
			return node.is_in_group("public_key")
		return false)
	if is_private_key and is_public_key:
		_sequence_approved()
	elif is_private_key and !is_public_key:
		_sequence_denied("НУЖЕН ПУБЛИЧНЫЙ КЛЮЧ")
	elif !is_private_key and is_public_key:
		_sequence_denied("НУЖЕН ТВОЙ ЛИЧНЫЙ КЛЮЧ")
	else:
		_sequence_denied("ВСТАВЬТЕ ВАШ ЛИЧНЫЙ И ПУБЛИЧНЫЙ КЛЮЧ 
ДЛЯ ВХОДА В КРИПТОКОШЕЛЕК")

#remove later
func _on_key_removed() -> void:
	if current_state == VaultState.OPEN:
		return
	current_state = VaultState.IDLE
	status_light.material_override = mat_idle
	status_label.text = "ВСТАВЬТЕ КЛЮЧ ДЛЯ ВХОДА В КРИПТОКОШЕЛЕК"
#remove later
func _on_key_inserted(key_object) -> void:
	if current_state == VaultState.OPEN:
		return
	if key_object.is_in_group("private_key"):
		_sequence_approved()
	elif key_object.is_in_group("public_key"):
		_sequence_denied("ПУБЛИЧНЫЙ КЛЮЧ — НЕ ПОДПИСЬ\nЭто ваш адрес, а не пароль\nИспользуйте ПРИВАТНЫЙ КЛЮЧ")
	elif key_object.is_in_group("wrong_key"):
		_sequence_denied("НЕПРАВИЛЬНЫЙ ЛИЧНЫЙ КЛЮЧ\nЭта подпись принадлежит другому\nТолько ВАШ ключ может подписывать")
	else:
		_sequence_denied("НЕПРАВИЛЬНЫЙ ОБЪЕКТ\nЭто не ключ")

# ── DENIED ──────────────────────────────────────────────────
func _sequence_denied(reason: String) -> void:
	if current_state == VaultState.DENIED:
		return
	current_state = VaultState.DENIED
	Signals.LevelError.emit()
	#sound_denied.play()
	status_label.text = "[!] ДОСТУП ЗАПРЕЩЕН\n" + reason

	# Красный пульс x3
	var tween = create_tween()
	for _i in range(3):
		tween.tween_callback(func():
			status_light.material_override = mat_denied)
		tween.tween_interval(0.18)
		tween.tween_callback(func():
			status_light.material_override = mat_idle)
		tween.tween_interval(0.18)
	
	current_state = VaultState.IDLE
	# Выбросить ключ через 1.5 сек
	#await get_tree().create_timer(1.5).timeout
	#if key_slot.has_method("drop_object"):
		#key_slot.drop_object()
	#current_state = VaultState.IDLE
	#status_label.text = "ВСТАВЬТЕ КЛЮЧ ДЛЯ ВХОДА В КРИПТОКОШЕЛЕК"
	#status_light.material_override = mat_idle

# ── APPROVED ─────────────────────────────────────────────────
func _sequence_approved() -> void:
	door_opening.emit()
	current_state = VaultState.DECRYPTING
	Signals.LevelSuccess.emit()
	#sound_approved.play()
	status_light.material_override = mat_approved
	await _animate_decrypting()
	reward.visible = true
	reward.enabled = true
	_open_door()
	await get_tree().create_timer(0.9).timeout
	status_label.text = "[✓] СЕЙФ ОТКРЫТ"
	current_state = VaultState.OPEN

func _animate_decrypting() -> void:
	var steps := [
		"[✓] ЛИЧНЫЙ КЛЮЧ ВЕРИФИЦИРУЕТСЯ",
		"[✓] ЛИЧНЫЙ КЛЮЧ ВЕРИФИЦИРУЕТСЯ\nПРОВЕРКА ПОДПИСИ.",
		"[✓] ЛИЧНЫЙ КЛЮЧ ВЕРИФИЦИРУЕТСЯ\nПРОВЕРКА ПОДПИСИ..",
		"[✓] ЛИЧНЫЙ КЛЮЧ ВЕРИФИЦИРУЕТСЯ\nПРОВЕРКА ПОДПИСИ...",
		"[✓] ПОДПИСЬ ДЕЙСТВИТЕЛЬНА\nВСКРЫТИЕ ХРАНИЛИЩА.",
		"[✓] ПОДПИСЬ ДЕЙСТВИТЕЛЬНА\nВСКРЫТИЕ ХРАНИЛИЩА..",
		"[✓] ПОДПИСЬ ДЕЙСТВИТЕЛЬНА\nВСКРЫТИЕ ХРАНИЛИЩА...",
	]
	for step in steps:
		status_label.text = step
		await get_tree().create_timer(0.35).timeout

func _open_door() -> void:
	animation_player.play("Open")
	#var tween = create_tween()
	#tween.tween_property(door, "rotation_degrees:y", -110.0, 1.2) \
		#.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_door_opened() -> void:
	door_opened.emit()

func reset() -> void:
	animation_player.play("RESET")
	reward.visible = false
	key_slot_left.drop_object()
	key_slot_left.enabled = false
	key_slot_right.drop_object()
	key_slot_right.enabled = false
	#key_slot.drop_object()
	#key_slot.enabled = false
	reward.drop()
	reward.enabled = false
	reward.set_deferred("transform", reward_init_transform)
	reward.set_deferred("linear_velocity", Vector3.ZERO)
	reward.set_deferred("angular_velocity", Vector3.ZERO)
	await get_tree().create_timer(0.2).timeout
	key_slot_left.enabled = true
	key_slot_right.enabled = true
	#key_slot.enabled = true
	status_light.material_override = mat_idle
	status_label.text = "ВСТАВЬТЕ ВАШ ЛИЧНЫЙ И ПУБЛИЧНЫЙ КЛЮЧ 
ДЛЯ ВХОДА В КРИПТОКОШЕЛЕК"
	current_state = VaultState.IDLE
