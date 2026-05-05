extends Node3D

@export var move_duration: float = 0.5
signal transmission_finished(success: bool)

func travel(path_nodes: Array) -> void:
    if path_nodes.size() < 2:
        transmission_finished.emit(false)
        queue_free()
        return
        
    var tween = create_tween()
    
    for i in range(1, path_nodes.size()):
        var next_node_id = path_nodes[i]
        var next_node = NetworkManager.nodes.get(next_node_id)
        if next_node:
            tween.tween_property(self, "global_position", next_node.global_position, move_duration)
        else:
            # Broken path midway somehow
            tween.kill()
            transmission_finished.emit(false)
            queue_free()
            return
            
    # Pulse effect at the end
    tween.tween_property(self, "scale", Vector3(2.0, 2.0, 2.0), 0.2)
    tween.tween_property(self, "scale", Vector3(0.0, 0.0, 0.0), 0.2)
    
    tween.tween_callback(func(): 
        transmission_finished.emit(true)
        queue_free()
    )
