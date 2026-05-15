extends Label3D

@export var level_index: int = 0

var is_one_shot_dialogue: bool = true
var one_shot_dialogue: String = "Loading to the game"

var dialogues := {
	0: ["Welcome to the Microcircuit.\n
		You will learn how trust works without a center." ],
	1: ["One block changed.\n 
		The chain broke.\n 
		This is why blockchains are tamper-proof."],
	2: ["Two keys. One secret.\n
		Guess which one opens the vault."],
	3: ["No boss. No center.\n 
		Just math. And agreement."],
	4: ["Thanks for Playing."]
}

func _on_staging_switching_to_loading_scene(user_data: Variant) -> void:
	if is_one_shot_dialogue:
		text = one_shot_dialogue
		is_one_shot_dialogue = false
		return
	if level_index >= dialogues.size():
		level_index = 0
	
	print(user_data)
	text = dialogues[level_index][0]
	level_index+=1
	
