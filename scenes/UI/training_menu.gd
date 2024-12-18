@tool
class_name TrainingMenu extends Control
const EXERCISE_META: StringName = &"Exercise"

const UP_ARROW_TEXTURE: Texture2D = preload("res://assets/UI/ArrowUp.svg")
const DOWN_ARROW_TEXTURE: Texture2D = preload("res://assets/UI/ArrowUp.svg")

# const UP_ARROW_UNICODE: int = 11014
# const DOWN_ARROW_UNICODE: int = 11015

@export var exercises: Array[Exercise]

@export_group("Node References")

@export var exercise_grid: GridContainer
@export var display_name_label: Label
@export var fatigue_arrow: Label

@export var main_stat_vbox: VBoxContainer
@export var skill_changes_hbox: HBoxContainer

@onready var exercise_label: Label = %ExerciseName

var stat_change_displays: Array[HBoxContainer]


func open() -> void:
	for but: BaseButton in exercise_grid.get_children():
		but.disabled = false
	focus_button(exercise_grid.get_child(0))


func close() -> void:
	for but: BaseButton in exercise_grid.get_children():
		but.disabled = true


func _ready() -> void:
	if skill_changes_hbox:
		for i: int in skill_changes_hbox.get_child_count():
			if i == 0 or not skill_changes_hbox.get_child(i) is HBoxContainer: continue
			stat_change_displays.push_back(skill_changes_hbox.get_child(i))
	
	if not exercise_grid:
		printerr("No Exercise Grid Set!!")
		return
	
	for child: Node in exercise_grid.get_children():
		child.free()
	
	for exercise: Exercise in exercises:
		var button: Button = Button.new()
		button.set_meta(EXERCISE_META, exercise)
		
		button.theme_type_variation = &"ButtonLeft"
		
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.name = exercise.name
		button.text = exercise.name
		
		button.mouse_entered.connect(focus_button.bind(button))
		button.focus_entered.connect(_on_exercise_focus_enter.bind(exercise))
		button.focus_exited.connect(_on_exercise_focus_exit.bind(exercise))
		button.pressed.connect(_on_exercise_pressed.bind(exercise))
		button.set_drag_forwarding(_get_exercise_drag_data.bind(exercise), Callable(), Callable())
		
		exercise_grid.add_child(button)
		button.owner = owner if owner else self
	
	close()
	main_stat_vbox.modulate.a = 0.0




func _get_exercise_drag_data(at_position: Vector2, exercise: Exercise) -> Variant:
	var lbl := Label.new()
	lbl.text = exercise.get_drag_preview()
	set_drag_preview(lbl)
	return exercise


func display_exercise(exercise: Exercise) -> void:
	if not exercise: return
	var set_stat_arrow: Callable = func(label: Label, value: int = 0, ) -> void:
		label.text = char(11014 if value > 0 else 11015).repeat(abs(value))
		label.modulate = Color(0.15, 0.4, 0.0, 1.0) if value > 0 else Color(0.45, 0.0, 0.0, 1.0)

	exercise_label.text = exercise.name
	set_stat_arrow.call(fatigue_arrow, exercise.fatigue)

	
	var stats: PackedStringArray = exercise.get_stat_changes()

	for i: int in stat_change_displays.size():
		if i < stats.size():
			set_stat_arrow.call(stat_change_displays[i].get_node(^"Arrow"), exercise.get(stats[i]))
			stat_change_displays[i].get_node(^"Stat").text = stats[i]
			stat_change_displays[i].show()
			continue
		stat_change_displays[i].hide()
		
	main_stat_vbox.modulate.a = 1.0


func focus_button(but: BaseButton) -> void:
	if but and but.visible and not but.button_pressed and not but.has_focus(): 
		but.grab_focus()


func _on_exercise_pressed(exercise: Exercise) -> void:
	Event.schedule_activity.emit(exercise)


func _on_exercise_focus_enter(exercise: Exercise) -> void:
	display_exercise(exercise)


func _on_exercise_focus_exit(exercise: Exercise) -> void:
	if exercise_label.text == exercise.name:
		main_stat_vbox.modulate.a = 0.0


func _get_minimum_size() -> Vector2:
	return get_child(0).get_combined_minimum_size() if get_child_count() else Vector2()
