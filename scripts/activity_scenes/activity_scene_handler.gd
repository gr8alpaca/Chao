@tool
class_name ActivitySceneHandler extends Node3D

const OVERLAY_SCENE: PackedScene = preload("res://scenes/UI/week_overlay.tscn")

signal resume(pet: Pet)

var overlay: WeekOverlay
var stats: Stats
var queue: Array[Activity]
var index: int = -1


func _init() -> void:
	overlay = preload("res://scenes/UI/week_overlay.tscn").instantiate()
	add_child(overlay, true, INTERNAL_MODE_FRONT)
	overlay.opened.connect(_on_overlay_opened)


func open(stats: Stats, queue: Array[Activity]) -> void:
	self.stats = stats
	self.queue = queue
	#overlay.init(stats)
	overlay.get_node(^"%NextWeekButton").pressed.connect(_on_next_week_pressed)


func close() -> void:
	print_rich("[color=pink]Closing activity scene handler...[/color]")
	
	await remove_current_scene()
	
	var garden : Garden = load(Main.PATH.GARDEN).instantiate()
	garden.pet_stats.push_back(stats)
	emit_signal(Main.SIGNAL_CHANGE, garden)


func advance_week() -> void:
	index += 1
	
	await remove_current_scene()
	
	if index >= queue.size():
		close()
		return
	
	var activity_scene: ActivityScene = queue[index].get_scene().instantiate()
	add_child(activity_scene, true)
	if not activity_scene.is_node_ready():
		await activity_scene.ready
	
	activity_scene.open(stats, queue[index])
	activity_scene.play()
	#overlay.open(queue[index], stats, index + 1)


func apply_activity_deltas() -> void:
	assert(-1 < index and index < queue.size(), "Index is OOB" )
	if not queue[index] is Exercise: return
	var deltas: Dictionary = ActivityXP.roll_exercise(queue[index])
	for stat: StringName in deltas.keys():
		stats.add_experience(stat, deltas[stat])


func remove_current_scene() -> void:
	if not get_child_count(): return
	var current_scene: ActivityScene = get_child(0)
	overlay.close()
	await overlay.closed
	remove_child(current_scene)
	current_scene.free()

func _on_next_week_pressed() -> void:
	advance_week()

func _on_overlay_opened() -> void:
	const STAT_CHANGE_DELAY: float = 0.5
	const BUTTON_ACTIVIATION_DELAY: float = 1.0
	var tw: Tween = create_tween()
	tw.tween_interval(STAT_CHANGE_DELAY)
	tw.tween_callback(apply_activity_deltas)
	tw.tween_interval(BUTTON_ACTIVIATION_DELAY )
	tw.tween_callback(overlay.set_button_active.bind(true))
