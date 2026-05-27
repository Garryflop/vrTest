extends Control

@onready var question_container: MarginContainer = $QuestionContainer
@onready var question_number: Label = $QuestionContainer/VBoxContainer/QuestionNumber
@onready var question_text: Label = $QuestionContainer/VBoxContainer/QuestionText
@onready var answer_options: ItemList = $QuestionContainer/VBoxContainer/AnswerOptions

@onready var explanation_panel: Panel = $ExplanationPanel
@onready var question_number_explanation: Label = $ExplanationPanel/ExplanationContainer/VBoxContainer/QuestionNumber
@onready var explanation_text: Label = $ExplanationPanel/ExplanationContainer/VBoxContainer/ExplanationText

@onready var results_panel: Panel = $ResultsPanel
@onready var results_text: Label = $"ResultsPanel/ResultsContainer/VBoxContainer/Results Text"
@onready var restart_button: Button = $ResultsPanel/ResultsContainer/VBoxContainer/RestartButton

var current_room_id: String = ""
var setted_room_id: String = "room_1"
var current_questions: Array = []
var current_question_idx: int = 0

var correct_answers_count: int = 0
var total_questions_count: int = 0

# Флаг блокировки интерфейса во время анимаций и переходов
var is_transitioning: bool = false

const COLOR_VALID = Color(0.0, 0.8, 0.2, 1.0)
const COLOR_INVALID = Color(0.9, 0.1, 0.1, 1.0)
const COLOR_BACKGROUND_OPACITY = 0.35

func _ready() -> void:
	question_container.modulate.a = 1.0
	explanation_panel.modulate.a = 0.0
	explanation_panel.hide()
	results_panel.hide()

# Глобальный перехват ввода на системном уровне (починит кнопку P)
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_P:
			if current_question_idx < total_questions_count and not results_panel.visible:
				print("DEBUG: Скип квиза для секции: ", current_room_id)
				skip_current_quiz()

func skip_current_quiz() -> void:
	is_transitioning = true
	correct_answers_count = total_questions_count
	current_question_idx = total_questions_count
	show_quiz_results()

func start_quiz(room_id: String) -> void:
	if not Globals.QUESTION_DATA.has(room_id):
		return
	
	is_transitioning = false
	results_panel.hide()
	explanation_panel.hide()
	explanation_panel.modulate.a = 0.0
	question_container.show()
	question_container.modulate.a = 1.0
	
	current_room_id = room_id
	var room_data = Globals.QUESTION_DATA[room_id]
	
	current_questions = room_data["questions"]
	total_questions_count = current_questions.size()
	
	current_question_idx = 0
	correct_answers_count = 0
	
	show_question()

func show_question() -> void:
	answer_options.clear()
	answer_options.max_columns = 1
	answer_options.same_column_width = true
	
	var q_data = current_questions[current_question_idx]
	question_number.text = "%d/%d" % [current_question_idx + 1, total_questions_count]
	question_text.text = q_data["question"]
	
	for option in q_data["options"]:
		answer_options.add_item(option)
		
	answer_options.deselect_all()
	is_transitioning = false # Разблокируем клики, когда вопрос полностью готов

func _on_answer_options_item_selected(index: int) -> void:
	# Защита: если анимация в процессе, игнорируем любые клики лазером
	if is_transitioning:
		return
		
	# Безопасность: проверяем, что индекс не вылетел за пределы массива данных
	if current_question_idx >= current_questions.size():
		return
		
	is_transitioning = true # Мгновенно блокируем повторные клики
	
	var q_data = current_questions[current_question_idx]
	
	var bg_correct = COLOR_VALID
	bg_correct.a = COLOR_BACKGROUND_OPACITY
	var bg_incorrect = COLOR_INVALID
	bg_incorrect.a = COLOR_BACKGROUND_OPACITY

	answer_options.set_item_custom_bg_color(q_data["correct_idx"], bg_correct)
	
	if index == q_data["correct_idx"]:
		correct_answers_count += 1
		current_question_idx += 1
		
		# Звук успеха (закомментирован)
		# if Signals.has_signal("PlaySound"):
		# 	Signals.PlaySound.emit("success")
			
		await get_tree().create_timer(0.8).timeout
		refresh_scene()
	else:
		answer_options.set_item_custom_bg_color(index, bg_incorrect)
		current_question_idx += 1
		
		# Звук ошибки (закомментирован)
		# if Signals.has_signal("PlaySound"):
		# 	Signals.PlaySound.emit("error")
			
		await get_tree().create_timer(0.4).timeout
		fade_switch_panels(question_container, explanation_panel, show_explanation)

func show_explanation() -> void:
	var q_data = current_questions[current_question_idx - 1]
	question_number_explanation.text = "%d/%d" % [current_question_idx, total_questions_count]
	explanation_text.text = "Неверно!\n\nРазбор: %s" % q_data["explanation"]
	explanation_text.add_theme_color_override("font_color", Color(1.0, 0.65, 0.2))
	is_transitioning = false # Разблокируем клики для кнопки "Далее"

func show_quiz_results() -> void:
	explanation_panel.hide()
	question_container.hide()
	results_panel.show()
	
	var score_percent: float = (float(correct_answers_count) / float(total_questions_count)) * 100.0
	
	if score_percent >= 50.0:
		results_text.text = "Тест пройден!\nПрогресс: %.1f%%" % score_percent
		results_text.add_theme_color_override("font_color", COLOR_VALID)
		
		restart_button.text = "Активировать портал"
		restart_button.modulate = COLOR_VALID
		
		# if Signals.has_signal("PlaySound"):
		# 	Signals.PlaySound.emit("quiz_perfect")
		Signals.QuizCompleted.emit()
	else:
		results_text.text = "Не сдано!\nПрогресс: %.1f%%" % score_percent
		results_text.add_theme_color_override("font_color", COLOR_INVALID)
		
		restart_button.text = "Заново пройти"
		restart_button.modulate = COLOR_INVALID
	
	is_transitioning = false

func refresh_scene() -> void:
	if current_question_idx < total_questions_count:
		show_question()
	else:
		show_quiz_results()

func fade_switch_panels(from_panel: Control, to_panel: Control, mid_callback: Callable) -> void:
	var tween = create_tween().set_parallel(false)
	tween.tween_property(from_panel, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		from_panel.hide()
		mid_callback.call()
		to_panel.show()
	)
	tween.tween_property(to_panel, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _on_restart_button_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	restart_button.modulate = Color.WHITE
	start_quiz(current_room_id)

func _on_next_button_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	fade_switch_panels(explanation_panel, question_container, refresh_scene)
