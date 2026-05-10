extends Node3D

@onready var key_label: Label3D       = $KeyLabel
@onready var hint_label: Label3D      = $HintLabel
@onready var beam_container: Node3D   = $BeamContainer

# Фиксированные точки куда тянутся линии (в локальных координатах)
# Настрой позиции под свою сцену в инспекторе или прямо здесь
var beam_targets: Array[Vector3] = [
	Vector3(-3.0, 0.0, -2.0),
	Vector3( 3.0, 0.0, -2.0),
	Vector3( 0.0, 0.0, -4.0),
]

var _beam_imm: ImmediateMesh
var _chars := "0123456789ABCDEF"

func _ready() -> void:
	hint_label.text = "PUBLIC KEY\nShare with anyone 🌐\nThis is your address"

	# Создаём один ImmediateMesh для всех линий
	var mesh_inst = MeshInstance3D.new()
	_beam_imm = ImmediateMesh.new()
	mesh_inst.mesh = _beam_imm
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0.6, 1, 0.7)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0, 0.5, 1)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_inst.material_override = mat
	beam_container.add_child(mesh_inst)

	_start_float_animation()
	_start_key_blink()
	_start_beam_animation()

# ── Плавное парение + вращение ───────────────────────────────
func _start_float_animation() -> void:
	var origin_y = position.y
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", origin_y + 0.08, 1.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", origin_y, 1.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var spin = create_tween().set_loops()
	spin.tween_property(self, "rotation_degrees:y", 360.0, 8.0) \
		.set_trans(Tween.TRANS_LINEAR)

# ── Мигание символов адреса ──────────────────────────────────
func _start_key_blink() -> void:
	var tween = create_tween().set_loops()
	tween.tween_callback(_update_key_text)
	tween.tween_interval(0.7)

func _update_key_text() -> void:
	var addr = ""
	for i in range(16):
		if i > 0 and i % 4 == 0:
			addr += " "
		addr += _chars[randi() % _chars.length()]
	key_label.text = addr

# ── Световые линии ───────────────────────────────────────────
func _start_beam_animation() -> void:
	# Пульсация прозрачности через процесс
	set_process(true)

var _beam_alpha: float = 0.7
var _beam_dir: float = -1.0

func _process(delta: float) -> void:
	# Пульс прозрачности линий
	_beam_alpha += delta * 0.8 * _beam_dir
	if _beam_alpha <= 0.2:
		_beam_dir = 1.0
	elif _beam_alpha >= 0.9:
		_beam_dir = -1.0
	_redraw_beams()

func _redraw_beams() -> void:
	_beam_imm.clear_surfaces()
	if beam_targets.is_empty():
		return
	_beam_imm.surface_begin(Mesh.PRIMITIVE_LINES)
	var origin = Vector3.ZERO  # локальный центр PublicKeyDisplay
	for target in beam_targets:
		_beam_imm.surface_add_vertex(origin)
		_beam_imm.surface_add_vertex(target)
	_beam_imm.surface_end()
