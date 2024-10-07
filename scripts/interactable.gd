@tool
class_name Interactable extends StaticBody3D
const GROUP: StringName = &"Interactable"
const SIGNAL_ENABLED: StringName = &"enable_input"
signal interacted

const ALPHA_MODULATE: float = 0.30
const TWEEN_INTERVAL: float = 0.25

@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var is_hovered: bool:
	set(val):
		is_hovered = val

		if is_hovered and modulate_material and (not highlight_tween or not highlight_tween.is_valid()):
			highlight_tween = create_tween().set_loops(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
			highlight_tween.tween_property(modulate_material, ^"albedo_color:a", ALPHA_MODULATE, TWEEN_INTERVAL)
			highlight_tween.tween_property(modulate_material, ^"albedo_color:a", 0.0, TWEEN_INTERVAL)

		elif highlight_tween:
			highlight_tween.kill()
			modulate_material.albedo_color.a = 0.0


@export var modulate_material: StandardMaterial3D
@export var hover_modulate: Color = Color.WHITE


@export var enabled: bool = true: set = set_enabled

var highlight_tween: Tween


func _init() -> void:
	collision_layer = 2
	collision_mask = 0


func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_mask & MOUSE_BUTTON_LEFT:
		interacted.emit()
		if get_parent() is Pet:
			Event.pet_interacted.emit(get_parent()) 

func _mouse_enter() -> void:
	is_hovered = true

func _mouse_exit() -> void:
	is_hovered = false


func set_enabled(val: bool) -> void:
	enabled = val
	input_ray_pickable = val
	input_capture_on_drag = val


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	if modulate_material:
		props.append({name=&"hover_modulate", type=TYPE_COLOR, })
	return props


func _notification(what: int) -> void:
	match what:

		NOTIFICATION_PARENTED:
			add_to_group(GROUP)
			
			if not Engine.is_editor_hint():
				var parent:= get_parent()
				parent.set_meta(GROUP, self)
				if not parent.has_user_signal(SIGNAL_ENABLED):
					parent.add_user_signal(SIGNAL_ENABLED, [{name = &"is_enabled", type = TYPE_BOOL}])
					parent.connect(SIGNAL_ENABLED, set_enabled)

		NOTIFICATION_EXIT_TREE:
			var parent: Node = get_parent()
			if get_parent().has_meta(GROUP):
				get_parent().remove_meta(GROUP, )
			if parent.has_user_signal(SIGNAL_ENABLED):
				parent.remove_user_signal(SIGNAL_ENABLED)