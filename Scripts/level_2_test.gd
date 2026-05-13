# level_2_test.gd
@tool
extends XRToolsSceneBase

var tether_scene: PackedScene = preload("res://Scenes/tether_line_cylinder.tscn")
var nodes: Array = []
var pipes: Array = []

@export_file('*.tscn') var next_level_scene : String

const INITIAL_TRANSACTION := 10

@onready var btn_reset: Button3D = $ResetButton

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	Signals.ConfirmNextLevel.connect(_on_confirm_next_level)

	nodes = [
		$blocks/BlockchainCube,
		$blocks/BlockchainCube2,
		$blocks/BlockchainCube3,
		$blocks/BlockchainCube4,
		$blocks/BlockchainCube5,
	]

	# Связи prev/next
	for i in range(nodes.size()):
		nodes[i].block_index = i
		if i > 0:
			nodes[i].prev_block = nodes[i - 1]
			nodes[i - 1].next_block = nodes[i]

	_init_chain()

	# Трубы
	for i in range(nodes.size() - 1):
		var pipe = _make_connection(nodes[i], nodes[i + 1])
		pipes.append(pipe)
		nodes[i].pipes.append(pipe)

	if btn_reset and btn_reset.has_signal("button_pressed"):
		btn_reset.button_pressed.connect(_on_reset)

func _init_chain() -> void:
	nodes[0].initialize(INITIAL_TRANSACTION, "")
	for i in range(1, nodes.size()):
		nodes[i].initialize(INITIAL_TRANSACTION, nodes[i - 1].block_hash)

func _on_reset() -> void:
	for node in nodes:
		node.reset()
	# После reset пересчитываем цепочку заново
	_init_chain()

func _make_connection(node_a, node_b) -> Node:
	var pipe_inst = tether_scene.instantiate()
	pipe_inst.cube = node_a.cube
	pipe_inst.connect_object = node_b.cube
	pipe_inst.is_placed = true
	pipe_inst.thickness = 5
	add_child(pipe_inst)
	return pipe_inst

func _on_confirm_next_level() -> void:
	load_scene(next_level_scene)
