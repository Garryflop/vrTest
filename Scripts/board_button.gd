extends Area3D

@export var action_name: String = ""

func _on_xr_pointer_pressed(_pos):
	if get_parent().has_method("click_action"):
		get_parent().click_action(action_name)
