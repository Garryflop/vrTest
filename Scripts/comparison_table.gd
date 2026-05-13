extends Node3D

@onready var label: Label3D = $Label3D

# Эти ноды передают данные через сигналы
@export var pow_table: NodePath
@export var pos_table: NodePath

var pow_time: float = 0.0
var pos_time: float = 0.0

func _ready() -> void:
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	_update_panel()

	#var pow2 = get_node_or_null(pow_table)
	#var pos = get_node_or_null(pos_table)
	#if pow2:
		#pow2.pow_completed.connect(_on_pow_done)
	#if pos:
		#pos.pos_completed.connect(_on_pos_done)

func _on_pow_done(t: float) -> void:
	pow_time = t
	_update_panel()

func _on_pos_done(t: float) -> void:
	pos_time = t
	_update_panel()

func _update_panel() -> void:
	var pow_str = "%.1fs" % pow_time if pow_time > 0 else "—"
	var pos_str = "%.1fs" % pos_time if pos_time > 0 else "—"
	label.text = """
╔══════════════════════════════════╗
║      CONSENSUS COMPARISON        ║
╠══════════════════════════════════╣
║  PROOF OF WORK  │ PROOF OF STAKE ║
║  ⚡ Energy: HIGH │ 🌱 Energy: LOW ║
║  🔥 Heat: MAX   │ ❄ Heat: NONE  ║
║  ⏱ Time: %s   │ ⏱ Time: %s   ║
╚══════════════════════════════════╝""" % [pow_str, pos_str]
