extends Area3D

var can_teleport: bool = false

func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsTeleportArea"

func _ready() -> void:
	Signals.QuizCompleted.connect(_on_quiz_completed)

func _on_quiz_completed() -> void:
	can_teleport = true

func _on_body_entered(body: Node3D) -> void:
	var player_body := body as XRToolsPlayerBody
	if not (player_body and can_teleport):
		return
	player_body.get_parent().get_node("FollowCameraMarker").visible = true

func _on_body_exited(body: Node3D) -> void:
	var player_body := body as XRToolsPlayerBody
	if not player_body:
		return
	player_body.get_parent().get_node("FollowCameraMarker").visible = false
