@tool
class_name Main extends Node3D

const PATH:={
	PET = "res://scenes/Pet/pet.tscn",
	GARDEN = "res://scenes/garden/garden.tscn",
	RACE = "res://scenes/race/race.tscn",
	DEFAULT = "res://scenes/garden/garden.tscn",
}

const SIGNAL_CHANGE: StringName = &"main_change"
## Allows current scene to exit without being freed.
const SIGNAL_EXIT: StringName = &"main_exit"
const SIGNAL_QUEUE_ADD: StringName = &"main_queue_add"
const SIGNAL_QUEUE_ADVANCE: StringName = &"main_queue_advance"

const TRANSITION_TIME_SEC: float = 1.3

@export_custom(3, "", 6) var start_scene: String = &"GARDEN"

var rect: ColorRect
var focus_label: Label

var queue: Array[Node]


func _ready() -> void:
	if Engine.is_editor_hint(): return
	process_mode = PROCESS_MODE_ALWAYS
	
	for child: Node in get_children():
		remove_child(child)
		add_child(child, false, INTERNAL_MODE_BACK)
	
	create_canvas()
	enter_scene(load(PATH[start_scene]).instantiate())



func change_scene(node: Node) -> void:
	if (get_scene() == node) or Engine.is_editor_hint(): return
	
	await exit_scene()
	enter_scene(node)


func enter_scene(node: Node) -> void:
	#print_debug("Entering Scene (%s)..." % node.name)
	if not node.has_user_signal(SIGNAL_CHANGE):
		node.add_user_signal(SIGNAL_CHANGE, [{name = "node", type = TYPE_OBJECT}])
	if not node.is_connected(SIGNAL_CHANGE, change_scene):
		node.connect(SIGNAL_CHANGE, change_scene)
	
	if not node.has_user_signal(SIGNAL_EXIT):
		node.add_user_signal(SIGNAL_EXIT)
	if not node.is_connected(SIGNAL_EXIT, exit_scene):
		node.connect(SIGNAL_EXIT, exit_scene.bind(false))
	
	if not node.has_user_signal(SIGNAL_QUEUE_ADD):
		node.add_user_signal(SIGNAL_QUEUE_ADD, [{name = "node", type = TYPE_OBJECT}])
	if not node.is_connected(SIGNAL_QUEUE_ADD, add_scene_to_queue):
		node.connect(SIGNAL_QUEUE_ADD, add_scene_to_queue)
	
	if not node.has_user_signal(SIGNAL_QUEUE_ADVANCE):
		node.add_user_signal(SIGNAL_QUEUE_ADVANCE)
	if not node.is_connected(SIGNAL_QUEUE_ADVANCE, advance_queue):
		node.connect(SIGNAL_QUEUE_ADVANCE, advance_queue)
	
	add_child(node, true)
	tween_modulate(false)


func exit_scene(free_scene: bool = true) -> void:
	#print_debug("Exiting Scene (%s)..." % (get_child(0).name if get_child_count() else ""))
	await tween_modulate(true).finished
	var scene: Node = get_scene()
	if scene: 
		remove_child(scene)
		if free_scene: 
			scene.free()


func add_scene_to_queue(node: Node) -> void:
	queue.push_back(node)

func advance_queue() -> void:
	change_scene(load(PATH.DEFAULT).instantiate() if queue.is_empty() else queue.pop_front())

func tween_modulate(hide_scene: bool, tween_speed: float = TRANSITION_TIME_SEC) -> Tween:
	var tw: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(0.1)
	tw.tween_property(rect, ^"modulate:a", 1.0 if hide_scene else 0.0, tween_speed)
	return tw

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
		elif Input.is_key_pressed(KEY_BRACKETRIGHT):
			
			print_orphan_nodes()

func get_scene() -> Node:
	return get_child(0) if get_child_count() else null


func create_canvas() -> void:
	if Engine.is_editor_hint(): return
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	rect = ColorRect.new()
	rect.visible = false
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color(0.0, 0.0, 0.0, 1.0)
	canvas.add_child(rect)
	focus_label = Label.new()
	canvas.add_child(focus_label)
	focus_label.position += Vector2(12, 12)
	focus_label.modulate.a = 0.4
	focus_label.hide()
	get_window().gui_focus_changed.connect(_on_gui_focus_changed)
	
	add_child(canvas, false, INTERNAL_MODE_FRONT)

func _on_gui_focus_changed(control: Control) -> void:
	focus_label.text = "Current Focus: %s" % (control.name if control else "None")

static func get_main() -> Main:
	return null if Engine.is_editor_hint() else Engine.get_main_loop().root.get_child(0)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"start_scene": property.hint_string = ",".join(PATH.keys())
