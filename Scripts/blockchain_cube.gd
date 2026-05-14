# blockchain_cube.gd
# Наследуем BlockchainComponent — он уже определён в blockchain_component.gd
extends BlockchainComponent

# ─── Данные блока ───────────────────────────────────────────
var transaction: int = 10
var block_hash: String = ""
var prev_hash: String = ""
var _original_prev_hash: String = "" 

var one_shot_ignore_sound: bool = true
var is_chain_valid: bool = true:
	set(value):
		is_chain_valid = value
		if one_shot_ignore_sound:
			one_shot_ignore_sound = false
		elif value:
			Signals.LevelSuccess.emit()
		else:
			Signals.LevelError.emit()

var next_block: Node3D = null
var prev_block: Node3D = null
var block_index: int = 0

# Начальные значения для reset
var _init_transaction: int = 10
var _init_prev_hash: String = ""

# Ссылки на трубы — заполняет уровень
var pipes: Array = []

# ─── Узлы ───────────────────────────────────────────────────
@onready var info_label: Label3D = $Cube/INFORMATION_LABEL
@onready var btn_up: Button3D = $Cube/ButtonUp
@onready var btn_down: Button3D = $Cube/ButtonDown

# ─── Материалы (назначить в инспекторе) ─────────────────────
@export var material_valid: StandardMaterial3D
@export var material_invalid: StandardMaterial3D

# ─── Ready ──────────────────────────────────────────────────
func _ready() -> void:
	super._ready()  # запускаем логику BlockchainComponent

	if btn_up and btn_up.has_signal("button_pressed"):
		btn_up.button_pressed.connect(_on_up)
	if btn_down and btn_down.has_signal("button_pressed"):
		btn_down.button_pressed.connect(_on_down)

	update_block_visuals()

# ─── Кнопки изменения транзакции ────────────────────────────
func _on_up() -> void:
	if transaction < 50:
		transaction += 10
		on_transaction_changed()

func _on_down() -> void:
	if transaction > 10:
		transaction -= 10
		on_transaction_changed()

# ─── Хэш-логика ─────────────────────────────────────────────
func _compute_hash(tran: int, p_hash: String) -> String:
	var raw = _hash_djb2(str(tran) + "|" + p_hash)
	return "%04x" % (raw & 0xFFFF)

func _hash_djb2(s: String) -> int:
	var h: int = 5381
	for c in s.to_utf8_buffer():
		h = ((h << 5) + h) + c
	return h & 0x7FFFFFFF

func initialize(p_transaction: int, p_prev_hash: String) -> void:
	_init_transaction = p_transaction
	_init_prev_hash = p_prev_hash
	_original_prev_hash = p_prev_hash
	transaction = p_transaction
	prev_hash = p_prev_hash
	one_shot_ignore_sound = true
	is_chain_valid = true
	block_hash = _compute_hash(transaction, prev_hash)
	update_block_visuals()

func on_transaction_changed() -> void:
	block_hash = _compute_hash(transaction, prev_hash)
	_animate_hash()
	update_block_visuals()
	if next_block and next_block.has_method("_receive_prev_hash"):
		next_block._receive_prev_hash(block_hash)

func _receive_prev_hash(incoming: String) -> void:
	is_chain_valid = (incoming == _original_prev_hash) if prev_block != null else true
	prev_hash = incoming
	block_hash = _compute_hash(transaction, prev_hash)
	_animate_hash()
	update_block_visuals()
	if next_block and next_block.has_method("_receive_prev_hash"):
		next_block._receive_prev_hash(block_hash)

# ─── Reset (переопределяем родительский) ────────────────────
func reset() -> void:
	super.reset()  # сброс позиции, скорости, состояния BlockchainComponent
	initialize(_init_transaction, _init_prev_hash)

# ─── Визуал ─────────────────────────────────────────────────
func update_block_visuals() -> void:
	_update_mesh_color()
	_update_label()
	_update_pipes()

func _update_mesh_color() -> void:
	if not is_instance_valid(cube_mesh):
		return
	if is_chain_valid:
		if material_valid:
			cube_mesh.material_override = material_valid
		else:
			# Фолбэк через albedo если материал не назначен
			cube_mesh.get_surface_override_material(0).albedo_color = Color(0, 1, 0)
	else:
		if material_invalid:
			cube_mesh.material_override = material_invalid
		else:
			cube_mesh.get_surface_override_material(0).albedo_color = Color(1, 0, 0)

func _update_label() -> void:
	if not is_instance_valid(info_label):
		return
	var status = "" if is_chain_valid else "\n⚠ INVALID"
	var ph = prev_hash if prev_hash != "" else "****"
	info_label.text = (
		"Block: #%d\nTran: %d BTC\nHash: %s\nP.Hash: %s%s"
		% [block_index, transaction, block_hash, ph, status]
	)

func _update_pipes() -> void:
	for pipe in pipes:
		if is_instance_valid(pipe) and pipe.has_method("set_invalid"):
			pipe.set_invalid(not is_chain_valid)

# ─── Анимация хэша ──────────────────────────────────────────
func _animate_hash() -> void:
	if not is_instance_valid(info_label):
		return
	var chars = "0123456789abcdef"
	var tween = create_tween()
	for _i in range(8):
		tween.tween_callback(func():
			var fake = ""
			for _j in range(4):
				fake += chars[randi() % chars.length()]
			var ph = prev_hash if prev_hash != "" else "****"
			info_label.text = (
				"Block #%d\nTran: %d BTC\nHash: %s\nP.Hash: %s"
				% [block_index, transaction, fake, ph]
			)
		)
		tween.tween_interval(0.05)
	tween.tween_callback(_update_label)
