extends Label3D

@export var level_index: int = 0

var is_one_shot_dialogue: bool = true
var one_shot_dialogue: String = tr("LOADING_DIALOGUE_ONE_SHOT")

var dialogues := {
	0: [tr("LOADING_DIALOGUE_0") ],
	1: [tr("LOADING_DIALOGUE_1")],
	2: [tr("LOADING_DIALOGUE_2")],
	3: [tr("LOADING_DIALOGUE_3")],
	4: [tr("LOADING_DIALOGUE_4")]
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
	
