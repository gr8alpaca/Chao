@tool
class_name ActivityScene extends Node3D

const FATIGUE_PER_POINT: int = 11
const FATIGUE_VARIANCE: int = 3

@export var initial_pet_state: StringName = &"sleep"

var auto_continue: bool = true

var stats: Stats
var activity: Activity
var week_index: int
var overlay: WeekOverlay



func init(stats: Stats, activity: Activity, week_index: int) -> void:
	self.stats = stats
	self.activity = activity
	self.week_index = week_index
	var pet: Pet = %Pet
	pet.stats = stats
	if pet.has_meta(StateMachine.GROUP):
		pet.get_meta(StateMachine.GROUP).initial_state_name = initial_pet_state


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	overlay = preload("res://scenes/UI/week_overlay.tscn").instantiate()
	add_child(overlay, true, INTERNAL_MODE_FRONT)
	overlay.init(activity, stats, week_index)
	
	overlay.get_node(^"%NextWeekButton").pressed.connect(emit_signal.bind(Main.SIGNAL_QUEUE_ADVANCE), CONNECT_ONE_SHOT)
	overlay.opened.connect(_on_overlay_opened)
	flicker_light()
	create_tween().tween_callback(_play)

## Override for custom behavior
func _play() -> void:
	overlay.open()

func roll_fatigue() -> int:
	var base_delta: int = activity.fatigue * FATIGUE_PER_POINT 
	var variance_roll : int = randi_range(-FATIGUE_VARIANCE * abs(activity.fatigue), FATIGUE_VARIANCE * abs(activity.fatigue))
	var rest_bonus: int = -stats.get_fatigue() / 2 if activity.name == &"rest" else 0
	return base_delta + variance_roll + rest_bonus
	

func roll_stat_changes() -> Dictionary:
	var deltas: Dictionary
	
	return deltas


func apply_activity_deltas() -> void:
	var fatigue_change: int = roll_fatigue()
	var deltas: Dictionary = roll_stat_changes()
	for stat: StringName in deltas.keys():
		stats.add_xp(stat, deltas[stat])


func _on_overlay_opened() -> void:
	const STAT_CHANGE_DELAY: float = 0.5
	const BUTTON_ACTIVIATION_DELAY_DEFAULT: float = 0.5
	const BUTTON_ACTIVIATION_DELAY_AUTO_CONTINUE: float = 2.0
	var tw: Tween = create_tween()
	tw.tween_interval(STAT_CHANGE_DELAY)
	tw.tween_callback(apply_activity_deltas)
	tw.tween_interval(BUTTON_ACTIVIATION_DELAY_AUTO_CONTINUE if auto_continue else BUTTON_ACTIVIATION_DELAY_DEFAULT)
	tw.tween_callback(overlay.next_week_button.emit_signal.bind(&"pressed") if auto_continue else overlay.set_button_active.bind(true))


func flicker_light() -> void:
	if not has_node(^"%SpotLight3D"): return
	const MIN_ENERGY: float = 6.0
	const MAX_ENERGY: float = 10.0
	const LIGHT_FLICKER_DURATION_SEC: float = 1.8
	var tw: Tween = create_tween().set_loops().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT_IN)
	tw.tween_callback(func randomize_speed_scale() -> void: tw.set_speed_scale(randf_range(0.2, 5.0)))
	tw.tween_property(%SpotLight3D, ^"light_energy", MIN_ENERGY, LIGHT_FLICKER_DURATION_SEC).from(MAX_ENERGY)
	tw.tween_property(%SpotLight3D, ^"light_energy", MAX_ENERGY, LIGHT_FLICKER_DURATION_SEC).from(MIN_ENERGY)
