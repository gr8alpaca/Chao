@tool
class_name Interactable extends Node
const GROUP: StringName = &"Interactable"

## connected to set_enabled(is_enabled: bool)
const SIGNAL_ENABLED: StringName = &"enable_input"

## _on_interaction_started() 
const SIGNAL_INTERACTION_STARTED: StringName = &"interaction_started"

## _on_interaction_ended()
const SIGNAL_INTERACTION_ENDED: StringName = &"interaction_ended"

@export var enabled: bool = true: set = set_enabled

## Overlay mesh will be changed to this node's modulate matrial
@export var hover_animation_nodes: Array[GeometryInstance3D] : set = set_hover_animation_nodes

var modulate_material: StandardMaterial3D

var highlight_tween: Tween 

func _init() -> void:
	add_to_group(GROUP)
	modulate_material = StandardMaterial3D.new()
	modulate_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	modulate_material.albedo_color = Color(1, 1, 1, 0.0)
	modulate_material.emission_enabled = true
	
	const ALPHA_MODULATE: float = 0.30
	const TWEEN_INTERVAL: float = 0.35
	highlight_tween = create_tween().set_loops(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	#highlight_tween.tween_property(modulate_material, ^"albedo_color:a", ALPHA_MODULATE, TWEEN_INTERVAL)
	highlight_tween.tween_property(modulate_material, ^"albedo_color:a", 0.0, TWEEN_INTERVAL).from(ALPHA_MODULATE)
	highlight_tween.finished
	reset_highlight()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED when not Engine.is_editor_hint(): 
			assert(get_parent() is CollisionObject3D, "Interactable parent is not of type 'CollisionObject3D'.")
			var parent: CollisionObject3D = get_parent()
			parent.input_event.connect(_on_input_event)
			parent.mouse_entered.connect(_on_mouse_entered)
			parent.mouse_exited.connect(_on_mouse_exited)
			add_and_connect(parent, SIGNAL_ENABLED, [ {name=&"is_enabled", type=TYPE_BOOL}], set_enabled)
			add_and_connect(parent, SIGNAL_INTERACTION_STARTED, [], _on_interaction_started)
			add_and_connect(parent, SIGNAL_INTERACTION_ENDED, [], _on_interaction_ended)

func reset_highlight() -> void:
	highlight_tween.stop()
	modulate_material.albedo_color.a = 0.0

func add_and_connect(node: Node, signal_name: StringName, arguments: Array[Dictionary]=[], callable: Callable = Callable()) -> void:
	if not node.has_user_signal(signal_name):
		node.add_user_signal(signal_name, arguments)
	if callable.is_valid() and not node.is_connected(signal_name, callable):
		node.connect(signal_name, callable)


func remove_and_disconect(node: Node, signal_name: StringName, callable: Callable = Callable()) -> void:
	if node.has_user_signal(signal_name):
		node.remove_user_signal(signal_name)
	if callable.is_valid() and node.is_connected(signal_name, callable):
		node.disconnect(signal_name, callable)


func _on_input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_mask & MOUSE_BUTTON_LEFT:
		get_parent().emit_signal(SIGNAL_INTERACTION_STARTED)

func _on_mouse_entered() -> void:
	if enabled: highlight_tween.play()

func _on_mouse_exited() -> void:
	highlight_tween.stop()
	modulate_material.albedo_color.a = 0.0

func _on_interaction_started() -> void:
	set_enabled(false)

func _on_interaction_ended() -> void:
	set_enabled(true)

func set_enabled(val: bool) -> void:
	enabled = val
	if not enabled:
		_on_mouse_exited()

func set_hover_animation_nodes(nodes: Array[GeometryInstance3D]) -> void:
	hover_animation_nodes = nodes
	if Engine.is_editor_hint(): return
	for node: GeometryInstance3D in nodes:
		node.material_overlay = modulate_material
