extends Node

signal packet_sent
signal transaction_complete(success: bool, path: Array)

# Graph structure: { node_id (String): [neighbor_ids (String)] }
var graph: Dictionary = {}

# Node references: { node_id (String): NetworkNode }
var nodes: Dictionary = {}

func clear_graph() -> void:
	graph.clear()
	nodes.clear()

func register_node(node_id: String, node_ref: Node3D) -> void:
	nodes[node_id] = node_ref
	if not graph.has(node_id):
		graph[node_id] = []

func add_connection(node_id_1: String, node_id_2: String) -> void:
	if not graph.has(node_id_1):
		graph[node_id_1] = []
	if not graph.has(node_id_2):
		graph[node_id_2] = []
		
	if not node_id_2 in graph[node_id_1]:
		graph[node_id_1].append(node_id_2)
	if not node_id_1 in graph[node_id_2]:
		graph[node_id_2].append(node_id_1)

# Find shortest path using BFS, only via ON nodes
func find_path(start_id: String, end_id: String) -> Array:
	if not nodes.has(start_id) or not nodes.has(end_id):
		return []
		
	if not nodes[start_id].is_on or not nodes[end_id].is_on:
		return []

	if start_id == end_id:
		return [start_id]
		
	var queue: Array = [start_id]
	var visited: Dictionary = {start_id: true}
	var parent: Dictionary = {}
	
	var found_path: bool = false
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == end_id:
			found_path = true
			break
			
		if graph.has(current):
			for neighbor in graph[current]:
				if not visited.has(neighbor):
					if nodes.has(neighbor) and nodes[neighbor].is_on:
						visited[neighbor] = true
						parent[neighbor] = current
						queue.append(neighbor)
						
	if not found_path:
		return []
		
	var path = []
	var curr = end_id
	while curr != start_id:
		path.insert(0, curr)
		curr = parent[curr]
	path.insert(0, start_id)
	
	return path
