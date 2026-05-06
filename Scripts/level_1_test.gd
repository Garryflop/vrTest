extends Node3D

var packet_scene: PackedScene = preload("res://Scenes/Objects/data_packet.tscn")
var pipe_scene: PackedScene = preload("res://Assets/Models/Pipes/Intact_Pipes.glb")
var tether_scene: PackedScene = preload("res://Scenes/tether_line_cylinder.tscn")

@onready var main_board = $MainBoard

var decent_node_ids = []
var cent_node_ids = []

var is_decent_looping = false
var is_cent_looping = false

func _ready() -> void:
	NetworkManager.clear_graph()
	
	if main_board:
		main_board.action_triggered.connect(_on_board_action)

	# Decentralized nodes references
	var d_nodes = [
		$DecentralizedComponents/BlockchainComponent,
		$DecentralizedComponents/BlockchainComponent2,
		$DecentralizedComponents/BlockchainComponent3,
		$DecentralizedComponents/BlockchainComponent4,
		$DecentralizedComponents/BlockchainComponent5,
		$DecentralizedComponents/BlockchainComponent6
	]
	
	# Register decentralized nodes securely with unique string IDs
	for i in range(d_nodes.size()):
		d_nodes[i].node_id = "Decent_" + str(i+1)
		decent_node_ids.append(d_nodes[i].node_id)
		NetworkManager.register_node(d_nodes[i].node_id, d_nodes[i])
	
	# Connect them in a ring/graph structure visually and logically
	for i in range(d_nodes.size()):
		var n1 = d_nodes[i]
		var n2 = d_nodes[(i + 1) % d_nodes.size()]
		
		# Add cross-chain connection for more "mesh/graph" like feel
		var n3 = d_nodes[(i + 2) % d_nodes.size()]
		
		make_connection(n1, n2)
		# make_connection(n1, n3) # Uncomment if you want a denser graph
		
	setup_centralized()

func make_connection(node_a: Node3D, node_b: Node3D) -> void:
	NetworkManager.add_connection(node_a.node_id, node_b.node_id)
	
	# Draw visual pipe between them
	var pipe_inst = tether_scene.instantiate()
	pipe_inst.cube = node_a.cube
	pipe_inst.connect_object = node_b.cube
	pipe_inst.is_placed = true
	pipe_inst.thickness = 5
	add_child(pipe_inst)
	
	#var distance = node_a.global_position.distance_to(node_b.global_position)
	#
	## Position midway and lower it down slightly
	#var mid_pos = (node_a.global_position + node_b.global_position) / 2
	#mid_pos.y -= 0.15
	#
	#var target_pos = node_b.global_position
	#target_pos.y -= 0.15
	#
	## Point A to B
	#pipe_inst.look_at_from_position(mid_pos, target_pos, Vector3.UP)
	#
	## Fix orientation so the pipe points its height towards the target
	#pipe_inst.rotate_object_local(Vector3(1, 0, 0), PI/2)
	#
	## Scale the pipe to stretch correctly and make it thinner
	## X and Z change the thickness, Y stretches the length
	#pipe_inst.scale = Vector3(0.15, distance / 2.0, 0.15) 

func setup_centralized() -> void:
	var central = $CentralizedComponents/CentralComponent
	var c_nodes = [
		$CentralizedComponents/BlockchainComponent,
		$CentralizedComponents/BlockchainComponent2,
		$CentralizedComponents/BlockchainComponent3,
		$CentralizedComponents/BlockchainComponent4,
		$CentralizedComponents/BlockchainComponent5
	]
	
	central.node_id = "CentralComponent"
	cent_node_ids.append(central.node_id)
	NetworkManager.register_node(central.node_id, central)
	
	for i in range(c_nodes.size()):
		var n = c_nodes[i]
		n.node_id = "Central_BC_" + str(i+1)
		cent_node_ids.append(n.node_id)
		NetworkManager.register_node(n.node_id, n)
		make_connection(central, n)
		
	print("Centralized Graph built: connected ", central.node_id, " to 4 surrounding nodes.")

func send_data(table_type: String) -> void:
	if table_type == "decent" and not is_decent_looping: return
	if table_type == "cent" and not is_cent_looping: return
	
	var pool = decent_node_ids if table_type == "decent" else cent_node_ids
	# Pick random start and end
	var start_node_id = pool[randi() % pool.size()]
	var end_node_id = pool[randi() % pool.size()]
	while end_node_id == start_node_id:
		end_node_id = pool[randi() % pool.size()]
		
	var path = NetworkManager.find_path(start_node_id, end_node_id)
	
	if path.size() > 0:
		print("Transaction successful, path: ", path)
		if main_board:
			main_board.set_status("Transaction Successful!\n" + start_node_id + " -> " + end_node_id)
		var packet = packet_scene.instantiate()
		add_child(packet)
		packet.global_position = NetworkManager.nodes[start_node_id].global_position
		
		# Connect to finished signal to wait for it before proceeding
		packet.transmission_finished.connect(func(success):
			await get_tree().create_timer(0.5).timeout
			send_data(table_type)
		)
		
		packet.travel(path)
	else:
		print("Transaction impossible - no path between ", start_node_id, " and ", end_node_id)
		if main_board:
			main_board.set_status("Transaction Impossible!\n" + start_node_id + " -X-> " + end_node_id)
			
		# Automatically try again after brief delay
		await get_tree().create_timer(1.0).timeout
		send_data(table_type)

func _on_board_action(action: String) -> void:
	if action == "send_decent":
		is_decent_looping = not is_decent_looping
		if main_board:
			main_board.set_button_text("send_decent", "Stop Decent" if is_decent_looping else "Send Decent")
		if is_decent_looping:
			send_data("decent")
			
	elif action == "send_cent":
		is_cent_looping = not is_cent_looping
		if main_board:
			main_board.set_button_text("send_cent", "Stop Cent" if is_cent_looping else "Send Cent")
		if is_cent_looping:
			send_data("cent")
			
	elif action == "reset":
		for node in NetworkManager.nodes.values():
			node.reset()
		if main_board:
			main_board.set_status("System Reset.\nAll nodes online.")
