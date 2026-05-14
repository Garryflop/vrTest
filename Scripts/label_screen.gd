extends Label3D

@export var level_index: int = 0
var dialogues := {
	0: ["Loading to the game"],
	1: ["Welcome to the Microcircuit.\n
		You will learn how trust works without a center." ],
	2: ["One block changed.\n 
		The chain broke.\n 
		This is why blockchains are tamper-proof."],
	3: ["Two keys. One secret.\n
		Guess which one opens the vault."],
	4: ["No boss. No center.\n 
		Just math. And agreement."]
}

func _on_staging_switching_to_loading_scene(user_data: Variant) -> void:
	if level_index >= dialogues.size():
		level_index = 0
	
	print(user_data)
	text = dialogues[level_index][0]
	level_index+=1
	
