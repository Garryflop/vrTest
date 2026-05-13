extends Node3D

@onready var select_button: Node      = $SelectButton
@onready var nodes_container: Node3D  = $NodeValidators

@export var mat_idle: StandardMaterial3D
@export var mat_waiting: StandardMaterial3D
@export var mat_winner: StandardMaterial3D
@export var mat_loser: StandardMaterial3D

signal pos_completed(time_seconds: float)

var is_running: bool = false
var stakes: Array = []  # stakes[i] = текущий стейк ноды i

var bag_init_transforms: Array = []
var bags: Array = []

func _ready() -> void:
	select_button.button_pressed.connect(_on_select)
	
	# Инициализируем стейки и подключаем сигналы
	var validators = nodes_container.get_children()
	for i in range(validators.size()):
		stakes.append(1)  # минимум 1
		var slot = validators[i].get_node_or_null("MoneyBagSnapZone")
		if slot:
			slot.has_picked_up.connect(_on_bag_placed.bind(i))
			slot.has_dropped.connect(_on_bag_removed.bind(i))
		else:
			push_warning("No MoneyBagSnapZone in " + validators[i].name)
	
	_update_stake_labels()
	
	bags = get_tree().get_nodes_in_group("Money")
	for bag in bags:
		bag_init_transforms.append(bag.global_transform)

func _on_bag_placed(_what, idx: int) -> void:
	stakes[idx] = 10
	_update_stake_labels()

func _on_bag_removed(idx: int) -> void:
	stakes[idx] = 1
	_update_stake_labels()

func _update_stake_labels() -> void:
	var validators = nodes_container.get_children()
	for i in range(min(validators.size(), stakes.size())):
		var label = validators[i].get_node_or_null("Label3D")
		if label:
			label.text = "Node %d\nStake: %d BTC" % [i + 1, stakes[i]]
		var mesh = validators[i].get_node_or_null("Cube/MeshInstance3D")
		if not mesh:
			mesh = validators[i].get_node_or_null("MeshInstance3D")
		if mesh and mat_waiting:
			var m = mat_waiting.duplicate()
			var brightness = clamp(stakes[i] / 10.0, 0.2, 1.0)
			m.emission = Color(0.2, 0.6, 1.0) * brightness
			mesh.material_override = m

func _on_select() -> void:
	if is_running:
		return
	is_running = true
	select_button.visible = false

	var validators = nodes_container.get_children()
	await get_tree().create_timer(0.8).timeout

	var winner_idx = _weighted_random(stakes)
	for i in range(validators.size()):
		if i == winner_idx:
			_set_node_visual(validators[i], "winner")
		else:
			_set_node_visual(validators[i], "loser")

	var label = validators[winner_idx].get_node_or_null("Label3D")
	if label:
		label.text = "✓ VALIDATOR\nStake: %d BTC\nSELECTED!" % stakes[winner_idx]

	await get_tree().create_timer(2.0).timeout
	_clear_table()
	pos_completed.emit(0.8)

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
		mesh = node.get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	match state:
		"idle":
			mesh.material_override = mat_idle
		"winner":
			mesh.material_override = mat_winner
		"loser":
			mesh.material_override = mat_loser

func reset() -> void:
	for validator in nodes_container.get_children():
		var slot = validator.get_node_or_null("MoneyBagSnapZone")
		if slot and slot.has_method("drop_object"):
			slot.drop_object()
	await get_tree().process_frame
	
	for i in range(bags.size()):
		bags[i].global_transform = bag_init_transforms[i]
		bags[i].visible = true
		bags[i].enabled = true
		if bags[i] is RigidBody3D:
			bags[i].linear_velocity = Vector3.ZERO
			bags[i].angular_velocity = Vector3.ZERO
	
	for i in range(stakes.size()):
		stakes[i] = 1
	is_running = false
	select_button.visible = true
	for node in nodes_container.get_children():
		_set_node_visual(node, "idle")
	_update_stake_labels()
