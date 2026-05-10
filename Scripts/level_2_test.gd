@tool
extends XRToolsSceneBase

var tether_scene: PackedScene = preload("res://Scenes/tether_line_cylinder.tscn")

var nodes

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	nodes = [
		$blocks/BlockchainCube,
		$blocks/BlockchainCube2,
		$blocks/BlockchainCube3,
		$blocks/BlockchainCube4
	]
	for i in range(len(nodes)-1):
		make_connection(nodes[i],nodes[i+1])


func make_connection(node_a: Node3D, node_b: Node3D) -> void:
	# Draw visual pipe between them
	var pipe_inst = tether_scene.instantiate()
	pipe_inst.cube = node_a.cube
	pipe_inst.connect_object = node_b.cube
	pipe_inst.is_placed = true
	pipe_inst.thickness = 5
	add_child(pipe_inst)
