extends Area3D

@onready var teleport_light: OmniLight3D = $TeleportLight
@onready var teleport_effect: MeshInstance3D = $TeleportEffect
@onready var teleport_label: Label3D = $TeleportLabel


var can_teleport: bool = false

func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsTeleportArea"

func _ready() -> void:
	Signals.QuizCompleted.connect(_on_quiz_completed)
	teleport_light.hide()
	teleport_effect.hide()
	teleport_label.show()

func _on_quiz_completed() -> void:
	can_teleport = true
	teleport_light.show()
	teleport_effect.show()
	teleport_label.hide()

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
