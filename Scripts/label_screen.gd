extends Label3D

@export var level_index: int = 0

var is_one_shot_dialogue: bool = true
var one_shot_dialogue: String = "Загрузка игры"

var dialogues := {
	0: ["Добро пожаловать в Микросхему.\n
		Здесь вы поймете, как устроено децентрализованное доверие." ],
	1: ["Один измененный блок — и цепочка разрушена.\n
		Именно поэтому блокчейны защищены от взлома."],
	2: ["Два ключа. Один секрет.\n
		Угадайте, какой именно откроет хранилище."],
	3: ["Без руководства. Без единого центра.\n 
		Только математика и консенсус."],
	4: ["Спасибо за игру."]
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
	
