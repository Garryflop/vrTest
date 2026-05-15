extends Node3D

@onready var pow_label_3d: Label3D = $PoWLabel3D
@onready var pos_label_3d: Label3D = $PoSLabel3D


# Эти ноды передают данные через сигналы
@export var pow_table: NodePath
@export var pos_table: NodePath

var pow_time: float = 0.0
var pos_time: float = 0.0

func _ready() -> void:
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
	pow_label_3d.text = "  PROOF OF WORK
⚡ Energy: HIGH 
🔥 Heat: MAX
⏱ Time: %s" % pow_str
	var pos_str = "%.1fs" % pos_time if pos_time > 0 else "—"
	pos_label_3d.text = " PROOF OF STAKE
🌱 Energy: LOW 
❄ Heat: NONE  
⏱ Time: %s" % pos_str
