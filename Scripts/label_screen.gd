extends Label3D

@export var level_index: int = 0
var dialogues := {
	0: ["Welcome to the Microcircuit.", 
		"You will learn how trust works without a center."],
	1: ["One block changed.", 
		"The chain broke.", 
		"This is why blockchains are tamper-proof."],
	2: ["Two keys. One secret.", 
		"Guess which one opens the vault."],
	3: ["No boss. No center.", 
		"Just math. And agreement."],
}

func _on_staging_switching_to_loading_scene(user_data: Variant) -> void:
	
	print(user_data)
	text = dialogues[level_index][0] + "\n" + dialogues[level_index][1]
	level_index+=1
