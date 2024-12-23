@tool
extends Node

const TRANSITION_TIME_SEC: float = 1.5

signal scene_changed(scene_node: Node)

var root: Window
var scene: Node : set = set_scene
var rect: ColorRect


func change_scene(node: Node) -> void:
	if scene == node or Engine.is_editor_hint(): return
	if scene:
		exit_scene(scene)
	await scene_changed
	enter_scene(node)
	set_process_input(true)


func enter_scene(node: Node) -> void:
	assert(node)
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)\
	.tween_callback(node.connect.bind(&"tree_entered", set_scene.bind(node)))\
	.tween_callback(add_sibling.bind(node))\
	.tween_interval(0.1)\
	.tween_property(rect, ^"modulate:a", 0.0, rect.modulate.a * TRANSITION_TIME_SEC)\
	.tween_callback(set_scene.bind(node))


func exit_scene(node: Node) -> void:
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)\
	.tween_property(rect, ^"modulate:a", 1.0, (1.0 - rect.modulate.a) * TRANSITION_TIME_SEC)\
	.tween_callback(get_parent().remove_child.bind(scene))\
	.tween_callback(scene.free)\
	.tween_callback(set_scene.bind(null))

func set_scene(node: Node) -> void:
	scene = node
	scene_changed.emit(node)

func _input(event: InputEvent) -> void:
	get_parent().set_input_as_handled()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			set_process_input(false)
			if Engine.is_editor_hint():
				return
				
			var root: Window = get_parent()
			if not root.is_node_ready():
				await root.ready
			
			scene = root.get_child(root.get_child_count()-1)
			
			var canvas: CanvasLayer = CanvasLayer.new()
			canvas.layer = 100
			
			rect = ColorRect.new()
			rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect.color = Color(0.0, 0.0, 0.0, 1.0)
			canvas.add_child(rect)
			root.add_child(canvas)
			create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)\
			.tween_property(rect, ^"modulate:a", 0.0, TRANSITION_TIME_SEC)
