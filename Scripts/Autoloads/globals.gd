extends Node

var is_completed_game: bool = false

func _ready() -> void:
	TranslationServer.set_locale("RUSSIAN")

var QUESTION_DATA = {
	"room_1": {
		"title": tr("ROOM_1_TITLE"),
		"questions": [
			{
				"question": tr("ROOM_1_QUESTION_1"),
				"options": [tr("ROOM_1_QUESTION_1_OPTION_0"), tr("ROOM_1_QUESTION_1_OPTION_1"), tr("ROOM_1_QUESTION_1_OPTION_2")],
				"correct_idx": 1,
				"explanation": "ROOM_1_QUESTION_1_EXPLANATION"
			},
			{
				"question": tr("ROOM_1_QUESTION_2"),
				"options": [tr("ROOM_1_QUESTION_2_OPTION_0"), tr("ROOM_1_QUESTION_2_OPTION_1"), tr("ROOM_1_QUESTION_2_OPTION_2")],
				"correct_idx": 0,
				"explanation": tr("ROOM_1_QUESTION_2_EXPLANATION")
			},
			{
				"question": tr("ROOM_1_QUESTION_3"),
				"options": [tr("ROOM_1_QUESTION_3_OPTION_0"), tr("ROOM_1_QUESTION_3_OPTION_1"), tr("ROOM_1_QUESTION_3_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_1_QUESTION_3_EXPLANATION")
			}
		]
	},
	"room_2": {
		"title": tr("ROOM_2_TITLE"),
		"questions": [
			{
				"question": tr("ROOM_2_QUESTION_1"),
				"options": [tr("ROOM_2_QUESTION_1_OPTION_0"), tr("ROOM_2_QUESTION_1_OPTION_1"), tr("ROOM_2_QUESTION_1_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_2_QUESTION_1_EXPLANATION")
			},
			{
				"question": tr("ROOM_2_QUESTION_2"),
				"options": [tr("ROOM_2_QUESTION_2_OPTION_0"), tr("ROOM_2_QUESTION_2_OPTION_1"), tr("ROOM_2_QUESTION_2_OPTION_2")],
				"correct_idx": 2,
				"explanation": tr("ROOM_2_QUESTION_2_EXPLANATION")
			},
			{
				"question": tr("ROOM_2_QUESTION_3"),
				"options": [tr("ROOM_2_QUESTION_3_OPTION_0"), tr("ROOM_2_QUESTION_3_OPTION_1"), tr("ROOM_2_QUESTION_3_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_2_QUESTION_3_EXPLANATION")
			}
		]
	},
	"room_3": {
		"title": tr("ROOM_3_TITLE"),
		"questions": [
			{
				"question": tr("ROOM_3_QUESTION_1"),
				"options": [tr("ROOM_3_QUESTION_1_OPTION_0"), tr("ROOM_3_QUESTION_1_OPTION_1"), tr("ROOM_3_QUESTION_1_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_3_QUESTION_1_EXPLANATION")
			},
			{
				"question": tr("ROOM_3_QUESTION_2"),
				"options": [tr("ROOM_3_QUESTION_2_OPTION_0"), tr("ROOM_3_QUESTION_2_OPTION_1"), tr("ROOM_3_QUESTION_2_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_3_QUESTION_2_EXPLANATION")
			},
			{
				"question": tr("ROOM_3_QUESTION_3"),
				"options": [tr("ROOM_3_QUESTION_3_OPTION_0"), tr("ROOM_3_QUESTION_3_OPTION_1"), tr("ROOM_3_QUESTION_3_OPTION_2")],
				"correct_idx": 0,
				"explanation": tr("ROOM_3_QUESTION_3_EXPLANATION")
			}
		]
	},
	"room_4": {
		"title": tr("ROOM_4_TITLE"),
		"questions": [
			{
				"question": tr("ROOM_4_QUESTION_1"),
				"options": [tr("ROOM_4_QUESTION_1_OPTION_0"), tr("ROOM_4_QUESTION_1_OPTION_1"), tr("ROOM_4_QUESTION_1_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_4_QUESTION_1_EXPLANATION")
			},
			{
				"question": tr("ROOM_4_QUESTION_2"),
				"options": [tr("ROOM_4_QUESTION_2_OPTION_0"), tr("ROOM_4_QUESTION_2_OPTION_1"), tr("ROOM_4_QUESTION_2_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_4_QUESTION_2_EXPLANATION")
			},
			{
				"question": tr("ROOM_4_QUESTION_3"),
				"options": [tr("ROOM_4_QUESTION_3_OPTION_0"), tr("ROOM_4_QUESTION_3_OPTION_1"), tr("ROOM_4_QUESTION_3_OPTION_2")],
				"correct_idx": 1,
				"explanation": tr("ROOM_4_QUESTION_3_EXPLANATION")
			}
		]
	}
}
