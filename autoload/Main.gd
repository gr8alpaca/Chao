@tool
class_name Main extends Node3D

const NONE_STRING_HINT: String = "None:255"
const TRANSITION_TIME_SEC: float = 1.5

@export var packed_scenes: Array[PackedScene]

@export var start_scene: PackedScene

var rect: ColorRect



func _ready() -> void:
	create_canvas()
	
	if Engine.is_editor_hint():
		rect.hide()
		return
	
	if start_scene:
		enter_scene(start_scene.instantiate())
	

func change_scene(node: Node) -> void:
	if (get_child_count() and get_child(0) == node) or Engine.is_editor_hint(): 
		return
	
	if get_child_count():
		exit_scene()
		await get_child(0).tree_exited
	
	enter_scene(node)


func enter_scene(node: Node) -> void:
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
	


func set_scenes(val: Array[PackedScene]) -> void:
	var i: int = val.size()
	while i > 0:
		i-=1
		if val.count(val[i]) > 1:
			val.remove_at(i)
	packed_scenes = val
	

func create_canvas() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	rect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color(0.0, 0.0, 0.0, 1.0)
	canvas.add_child(rect)
	
	if not Engine.is_editor_hint():
		var focus_label: Label = Label.new()
		canvas.add_child(focus_label)
		focus_label.position += Vector2(12, 12)
		get_window().gui_focus_changed.connect(_on_gui_focus_changed.bind(focus_label))
		
	add_child(canvas, false, INTERNAL_MODE_FRONT)

func _on_gui_focus_changed(control: Control, lbl: Label) -> void:
	lbl.text = "Current Focus: %s" % (control.name if control else "None")
