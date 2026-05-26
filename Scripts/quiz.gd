extends Control

@onready var question_number: Label = $QuestionContainer/VBoxContainer/QuestionNumber
@onready var question_text: Label = $QuestionContainer/VBoxContainer/QuestionText
@onready var answer_options: ItemList = $QuestionContainer/VBoxContainer/AnswerOptions

@onready var explanation_panel: Panel = $ExplanationPanel
@onready var question_number_explanation: Label = $ExplanationPanel/ExplanationContainer/VBoxContainer/QuestionNumber
@onready var explanation_text: Label = $ExplanationPanel/ExplanationContainer/VBoxContainer/ExplanationText

@onready var results_panel: Panel = $ResultsPanel
@onready var results_text: Label = $"ResultsPanel/ResultsContainer/VBoxContainer/Results Text"

var current_room_id: String = ""
var setted_room_id: String = "room_1"
var current_questions: Array = []
var current_question_idx: int = 0

var correct_answers_count: int = 0
var total_questions_count: int = 0

#func _ready() -> void:
	#start_quiz(setted_room_id)

func start_quiz(room_id: String) -> void:
	if not Globals.QUESTION_DATA.has(room_id):
		return
	results_panel.hide()
	explanation_panel.hide()
	
	current_room_id = room_id
	var room_data = Globals.QUESTION_DATA[room_id]
	
	current_questions = room_data["questions"]
	total_questions_count = current_questions.size()
	
	current_question_idx = 0
	correct_answers_count = 0
	
	explanation_panel.hide()
	
	show_question()

func show_question() -> void:
	explanation_panel.hide()
	
	answer_options.clear()
	var q_data = current_questions[current_question_idx]
	question_number.text = "%d/%d" % [current_question_idx+1,total_questions_count]
	question_text.text = q_data["question"]
	var options = q_data["options"]
	for option in options:
		answer_options.add_item(option)

func _on_answer_options_item_selected(index: int) -> void:
	var q_data = current_questions[current_question_idx]
	if index == q_data["correct_idx"]:
		correct_answers_count += 1
	current_question_idx += 1
	if index == q_data["correct_idx"]:
		refresh_scene()
	else:
		show_explanation()
	

func show_explanation() -> void:
	var q_data = current_questions[current_question_idx-1]
	question_number_explanation.text = "%d/%d" % [current_question_idx,total_questions_count]
	explanation_text.text = q_data["explanation"]
	explanation_panel.show()
	

func show_quiz_results() -> void:
	results_panel.show()
	var score_percent: float = (float(correct_answers_count) / float(total_questions_count)) * 100.0
	if score_percent >= 50.0:
		results_text.text = "Успешно! Прогресс: %.1f%%" % score_percent
		Signals.QuizCompleted.emit()
	else:
		results_text.text = "Не сдано! Прогресс: %.1f%%" % score_percent

func refresh_scene() -> void:
	if current_question_idx < total_questions_count:
		show_question()
	else:
		show_quiz_results()

func _on_restart_button_pressed() -> void:
	start_quiz(current_room_id)


func _on_next_button_pressed() -> void:
	refresh_scene()
