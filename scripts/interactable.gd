@tool
class_name Interactable extends StaticBody3D
const GROUP: StringName = &"Interactable"


## connected to set_enabled(is_enabled: bool)
const SIGNAL_ENABLED: StringName = &"enable_input"

## _on_interaction_started() 
const SIGNAL_INTERACTION_STARTED: StringName = &"interaction_started"

## _on_interaction_ended()
const SIGNAL_INTERACTION_ENDED: StringName = &"interaction_ended"
#
#const SIGNAL_HOVER_STARTED: StringName = &"hover_started"
#const SIGNAL_HOVER_ENDED: StringName = &"hover_ended"
#


var is_hovered: bool:
	set(val):
		is_hovered = val
		
		const ALPHA_MODULATE: float = 0.30
		const TWEEN_INTERVAL: float = 0.25
		
		if is_hovered:
			var highlight_tween: Tween = create_tween().set_loops(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
			highlight_tween.tween_property(modulate_material, ^"albedo_color:a", ALPHA_MODULATE, TWEEN_INTERVAL)
			highlight_tween.tween_property(modulate_material, ^"albedo_color:a", 0.0, TWEEN_INTERVAL)
			
			mouse_exited.connect(highlight_tween.kill)
			
			
		#if is_hovered and modulate_material and (not highlight_tween or not highlight_tween.is_valid()):
			#highlight_tween = create_tween().set_loops(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
			#highlight_tween.tween_property(modulate_material, ^"albedo_color:a", ALPHA_MODULATE, TWEEN_INTERVAL)
			#highlight_tween.tween_property(modulate_material, ^"albedo_color:a", 0.0, TWEEN_INTERVAL)
		#
		#elif highlight_tween:
			#highlight_tween.kill()
			#modulate_material.albedo_color.a = 0.0


var modulate_material: StandardMaterial3D

@export var enabled: bool = true: set = set_enabled
@export var hover_modulate: bool = true

@export var hover_animation_nodes: Array[GeometryInstance3D] : set = set_hover_animation_nodes

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
	modulate_material = StandardMaterial3D.new()
	modulate_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	modulate_material.albedo_color = Color(1, 1, 1, 0.0)
	modulate_material.emission_enabled = true
	mouse_exited.connect(modulate_material.set_indexed.bind(^"albedo_color:a", 0.0), CONNECT_DEFERRED)
	
	
func set_hover_animation_nodes(nodes: Array[GeometryInstance3D]) -> void:
	hover_animation_nodes = nodes
	
	if Engine.is_editor_hint(): return
	for node: GeometryInstance3D in nodes:
		node.material_overlay = modulate_material



func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_mask & MOUSE_BUTTON_LEFT:
		get_parent().emit_signal(SIGNAL_INTERACTION_STARTED,)

func _mouse_enter() -> void:
	is_hovered = true

func _mouse_exit() -> void:
	is_hovered = false


func _on_interaction_started() -> void:
	set_enabled(false)

func _on_interaction_ended() -> void:
	set_enabled(true)


func set_enabled(val: bool) -> void:
	enabled = val
	input_ray_pickable = val
	input_capture_on_drag = val


#region Component


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED when not Engine.is_editor_hint():
			add_to_group(GROUP)

			var parent := get_parent()
			parent.set_meta(GROUP, self)
			add_and_connect(parent, SIGNAL_ENABLED, [ {name=&"is_enabled", type=TYPE_BOOL}], set_enabled)
			add_and_connect(parent, SIGNAL_INTERACTION_STARTED, [], _on_interaction_started)
			add_and_connect(parent, SIGNAL_INTERACTION_ENDED, [], _on_interaction_ended)
				

		NOTIFICATION_EXIT_TREE when not Engine.is_editor_hint():
			var parent: Node = get_parent()

			if parent.has_meta(GROUP):
				parent.remove_meta(GROUP)


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
