extends Node3D

@onready var energy_meter: Label3D   = $EnergyMeter
@onready var start_button: Node      = $StartButton
@onready var nodes_container: Node3D = $NodeMiners
@onready var cables: Array           = $Cables.get_children()

@export var mat_idle: StandardMaterial3D
@export var mat_mining: StandardMaterial3D
@export var mat_winner: StandardMaterial3D
@export var mat_loser: StandardMaterial3D

signal pow_completed(time_seconds: float)

var is_running: bool = false
var start_time: float = 0.0
var sockets: Array = []
var connected_count: int = 0

func _ready() -> void:
	start_button.button_pressed.connect(_on_start)
	
	for miner in nodes_container.get_children():
		var socket = miner.get_node_or_null("Socket")
		if socket:
			sockets.append(socket)
			socket.has_picked_up.connect(_on_cable_connected)
			socket.has_dropped.connect(_on_cable_disconnected)
		else:
			push_warning("No Socket in " + miner.name)
	
	_update_energy_meter()

# ── Энергия ──────────────────────────────────────────────────
func _on_cable_connected(_what) -> void:
	connected_count += 1
	_update_energy_meter()

func _on_cable_disconnected() -> void:
	connected_count = max(0, connected_count - 1)
	_update_energy_meter()

func _get_connected_count() -> int:
	return connected_count

func _update_energy_meter() -> void:
	var total = max(sockets.size(), 1)
	var percent = int((float(connected_count) / total) * 100)
	energy_meter.text = "Energy Meter\n%d%%" % percent
	if percent < 40:
		energy_meter.modulate = Color(1, 0.2, 0.2)
	elif percent < 80:
		energy_meter.modulate = Color(1, 0.8, 0.0)
	else:
		energy_meter.modulate = Color(0.2, 1, 0.2)

# ── Старт ────────────────────────────────────────────────────
func _on_start() -> void:
	if is_running:
		return
	if connected_count == 0:
		energy_meter.text = "⚠ Connect cables\nfirst!"
		return

	is_running = true
	start_time = Time.get_ticks_msec() / 1000.0
	start_button.visible = false

	var miners = nodes_container.get_children()
	var energy_ratio = float(connected_count) / max(sockets.size(), 1)
	var base_time = lerp(8.0, 2.0, energy_ratio)

	var times: Array = []
	for miner in miners:
		times.append(randf_range(base_time, base_time * 1.8))
		_set_node_visual(miner, "mining")

	var winner_time = times.min()
	var winner_idx = times.find(winner_time)
	energy_meter.text = "⛏ MINING...\n%d%% power" % int(energy_ratio * 100)

	for i in range(miners.size()):
		var t = times[i]
		var miner = miners[i]
		var tween = create_tween()
		tween.tween_interval(t)
		tween.tween_callback(func():
			if i == winner_idx:
				_on_winner_found(miner, winner_time, energy_ratio)
			else:
				_set_node_visual(miner, "loser")
		)

# ── Победитель ───────────────────────────────────────────────
func _on_winner_found(winner_node: Node3D, elapsed: float, energy_ratio: float) -> void:
	_set_node_visual(winner_node, "winner")

	var label = winner_node.get_node_or_null("INFORMATION_LABEL")
	if label:
		label.text = "⛏ WINNER!\nTime: %.1fs" % elapsed

	var efficiency = "LOW ⚡⚡⚡" if energy_ratio < 0.8 else "HIGH ⚡"
	energy_meter.text = "✓ BLOCK FOUND!\nTime: %.1fs\nWaste: %s" % [elapsed, efficiency]

	await get_tree().create_timer(2.0).timeout
	_clear_table()
	pow_completed.emit(Time.get_ticks_msec() / 1000.0 - start_time)

# ── Очистка стола ────────────────────────────────────────────
func _clear_table() -> void:
	# Дропаем кабели из сокетов
	for socket in sockets:
		if socket.has_method("drop_object"):
			socket.drop_object()
	
	await get_tree().process_frame
	
	for cable in cables:
		cable.visible = false
	
	for miner in nodes_container.get_children():
		_set_node_visual(miner, "idle")
		var label = miner.get_node_or_null("INFORMATION_LABEL")
		if label:
			label.text = ""
	
	await get_tree().create_timer(0.3).timeout
	_restore_cables()
	
	connected_count = 0
	start_button.visible = true
	is_running = false
	energy_meter.text = "Energy Meter\n0%"
	energy_meter.modulate = Color(1, 1, 1)

func _restore_cables() -> void:
	for cable in cables:
		cable.visible = true
		cable.enabled = true

# ── Визуал нод ───────────────────────────────────────────────
func _set_node_visual(node: Node3D, state: String) -> void:
	var mesh = node.get_node_or_null("Cube/MeshInstance3D")
	if not mesh:
		mesh = node.get_node_or_null("MeshInstance3D")
	if not mesh:
		push_warning("No mesh in " + node.name)
		return
	match state:
		"mining":
			mesh.material_override = mat_mining
			_start_blink(node)
		"winner":
			_stop_blink(node)
			mesh.material_override = mat_winner
		"loser":
			_stop_blink(node)
			mesh.material_override = mat_loser
		"idle":
			_stop_blink(node)
			mesh.material_override = mat_idle

func _start_blink(node: Node3D) -> void:
	if node.has_meta("blink"):
		return
	var mesh = node.get_node_or_null("Cube/MeshInstance3D")
	if not mesh:
		mesh = node.get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	var t = create_tween().set_loops()
	t.tween_callback(func(): mesh.material_override = mat_mining)
	t.tween_interval(0.3)
	t.tween_callback(func(): mesh.material_override = mat_idle)
	t.tween_interval(0.3)
	node.set_meta("blink", t)

func _stop_blink(node: Node3D) -> void:
	if node.has_meta("blink"):
		node.get_meta("blink").kill()
		node.remove_meta("blink")
