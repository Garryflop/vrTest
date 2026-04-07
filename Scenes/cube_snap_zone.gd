@tool
extends XRToolsSnapZone




func _on_has_picked_up(what: Variant) -> void:
	print("Picked up:",what)
	#print("Locking")
	#enabled = false
