extends StaticBody3D

@export var action_name: String = ""

# For FPS RayCast interactions (our custom method)
func _on_xr_pointer_pressed(_pos):
	if get_parent().has_method("click_action"):
		get_parent().click_action(action_name)

# For Godot XR Tools Pointer interactions
func pointer_event(event) -> void:
	# event.event_type == 2 is PRESSED in XRToolsPointerEvent.Type
	if event.event_type == 2:
		if get_parent().has_method("click_action"):
			get_parent().click_action(action_name)

