extends Node3D

@onready var select_button: Node      = $SelectButton
@onready var nodes_container: Node3D  = $NodeValidators

@export var mat_idle: StandardMaterial3D
@export var mat_waiting: StandardMaterial3D
@export var mat_winner: StandardMaterial3D
@export var mat_loser: StandardMaterial3D

signal pos_completed(time_seconds: float)

var is_running: bool = false

func _ready() -> void:
	select_button.button_pressed.connect(_on_select)
	_update_stake_labels()

# Стейк считаем по proximity — какой мешок ближайший к ноде
func _get_stakes() -> Array:
	var stakes = []
	var validators = nodes_container.get_children()
	for validator in validators:
		var slot = validator.get_node_or_null("BagSlot")
		if slot and slot.has_method("get_snapped_object"):
			var obj = slot.get_snapped_object()
			stakes.append(10 if obj != null else 1)
		else:
			stakes.append(1)
	return stakes

func _update_stake_labels() -> void:
	var validators = nodes_container.get_children()
	var stakes = _get_stakes()
	for i in range(min(validators.size(), stakes.size())):
		var label = validators[i].get_node_or_null("INFORMATION_LABEL")
		if label:
			label.text = "Node %d\nStake: %d BTC" % [i + 1, stakes[i]]
		var mesh = validators[i].get_node_or_null("Cube/MeshInstance3D")
		if mesh and mat_waiting:
			var m = mat_waiting.duplicate()
			var brightness = clamp(stakes[i] / 30.0, 0.2, 1.0)
			m.emission = Color(0.2, 0.6, 1.0) * brightness
			mesh.material_override = m

func _on_select() -> void:
	if is_running:
		return
	is_running = true
	select_button.visible = false

	# Обновляем стейки прямо перед выбором
	_update_stake_labels()

	var start_time = Time.get_ticks_msec() / 1000.0
	var validators = nodes_container.get_children()
	var stakes = _get_stakes()

	await get_tree().create_timer(0.8).timeout

	var winner_idx = _weighted_random(stakes)
	for i in range(validators.size()):
		if i == winner_idx:
			_set_node_visual(validators[i], "winner")
		else:
			_set_node_visual(validators[i], "loser")

	var label = validators[winner_idx].get_node_or_null("INFORMATION_LABEL")
	if label:
		label.text = "✓ VALIDATOR\nStake: %d BTC\nSELECTED!" % stakes[winner_idx]

	await get_tree().create_timer(2.0).timeout
	_clear_table()
	pos_completed.emit(Time.get_ticks_msec() / 1000.0 - start_time)

func _weighted_random(weights: Array) -> int:
	var total = 0
	for w in weights:
		total += w
	var roll = randi() % total
	var cumulative = 0
	for i in range(weights.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return i
	return weights.size() - 1

func _clear_table() -> void:
	for node in nodes_container.get_children():
		_set_node_visual(node, "idle")
	select_button.visible = true
	is_running = false
	_update_stake_labels()

func _set_node_visual(node: Node3D, state: String) -> void:
	var mesh = node.get_node_or_null("Cube/MeshInstance3D")
	if not mesh:
		return
	match state:
		"idle":   mesh.material_override = mat_idle
		"winner": mesh.material_override = mat_winner
		"loser":  mesh.material_override = mat_loser
