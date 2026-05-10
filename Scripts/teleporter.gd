extends Area3D

func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsTeleportArea"

func _on_body_entered(body: Node3D) -> void:
	var player_body := body as XRToolsPlayerBody
	if not player_body:
		return
	player_body.get_parent().get_node("FollowCameraMarker").visible = true



func _on_body_exited(body: Node3D) -> void:
	var player_body := body as XRToolsPlayerBody
	if not player_body:
		return
	player_body.get_parent().get_node("FollowCameraMarker").visible = false
