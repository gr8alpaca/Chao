@tool
class_name Main extends Node3D


const SIGNAL_CHANGE: StringName = &"main_change"
#const SIGNAL_ENTER: StringName = &"main_enter"
#const SIGNAL_EXIT: StringName = &"main_exit"

const TRANSITION_TIME_SEC: float = 1.5

#const DEFAULT_SCENE_PATH: String = "res://scenes/garden/garden.tscn"

const PATH:={
	PET = "res://scenes/Pet/pet.tscn",
	GARDEN = "res://scenes/garden/garden.tscn",
	RACE = "res://scenes/race/race.tscn",
	
	DEFAULT = "res://scenes/garden/garden.tscn",
}

var rect: ColorRect
var focus_label: Label 

var queue: Array[Node]

func _ready() -> void:
	create_canvas()
	
	if Engine.is_editor_hint():
		rect.hide()
		return
	
	enter_scene(load(PATH.GARDEN).instantiate())
	
	Event.change_scene.connect(change_scene)
	Event.queue_scene.connect(add_scene_to_queue)
	Event.advance_scene_queue.connect(advance_queue)

func change_scene(node: Node) -> void:
	if (get_child_count() and get_child(0) == node) or Engine.is_editor_hint(): 
		return
	
	if get_child_count():
		exit_scene()
		await get_child(0).tree_exited
	
	enter_scene(node)


func enter_scene(node: Node) -> void:
	
	if not node.has_user_signal(SIGNAL_CHANGE):
		node.add_user_signal(SIGNAL_CHANGE, [{name = "node", type = TYPE_OBJECT}])
	if not node.is_connected(SIGNAL_CHANGE, change_scene):
		node.connect(SIGNAL_CHANGE, change_scene)
	
	#if not node.has_user_signal(SIGNAL_ENTER):
		#node.add_user_signal(SIGNAL_ENTER, [{name = "node", type = TYPE_OBJECT}])
	#if not node.is_connected(SIGNAL_ENTER, enter_scene):
		#node.connect(SIGNAL_ENTER, change_scene)
	
	add_child(node, true)
	var tw: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(0.1)
	tw.tween_property(rect, ^"modulate:a", 0.0, rect.modulate.a * TRANSITION_TIME_SEC)
	tw.tween_callback(rect.hide)


func exit_scene() -> void:
	if not get_child_count(): return
	var tw: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(rect.show)
	tw.tween_property(rect, ^"modulate:a", 1.0, (1.0 - rect.modulate.a) * TRANSITION_TIME_SEC)
	tw.tween_callback(remove_child.bind(get_child(0)))
	tw.tween_callback(get_child(0).free)

func add_scene_to_queue(node: Node) -> void:
	if not node in queue:
		queue.push_back(node)


func advance_queue() -> void:
	if queue.is_empty():
		change_scene(load(PATH.DEFAULT).instantiate())
	else:
		change_scene(queue.pop_front())



func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		if Input.is_key_pressed(KEY_9):
			focus_label.visible = !focus_label.visible
		elif Input.is_key_pressed(KEY_P):
			get_tree().paused = !get_tree().paused
			
		elif Input.is_key_pressed(KEY_PERIOD):
			Engine.time_scale *= 2.0
			print("Time Scale -> %3.0d%%" % (Engine.time_scale * 100.0))
		elif Input.is_key_pressed(KEY_COMMA):
			Engine.time_scale /= 2.0
			print("Time Scale -> %3.0d%%" % (Engine.time_scale * 100.0))


func create_canvas() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	rect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color(0.0, 0.0, 0.0, 1.0)
	canvas.add_child(rect)
	get_tree().paused
	if not Engine.is_editor_hint():
		focus_label = Label.new()
		canvas.add_child(focus_label)
		focus_label.position += Vector2(12, 12)
		focus_label.modulate.a = 0.4
		focus_label.hide()
		get_window().gui_focus_changed.connect(_on_gui_focus_changed)
		
	add_child(canvas, false, INTERNAL_MODE_FRONT)

func _on_gui_focus_changed(control: Control) -> void:
	focus_label.text = "Current Focus: %s" % (control.name if control else "None")
