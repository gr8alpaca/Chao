@tool
class_name Pet extends CharacterBody3D

const RUN_SPEED_MIN: float = 0.5
const RUN_SPEED_MAX: float = 5.0

const TARGET_DISTANCE_THRESHOLD: float = 0.04

signal move_started
signal move_ended

@onready var state_machine: StateMachine = $StateMachine

@export var stats: Stats: set = set_stats

@export_range(0.5, 3.0, 0.1, "suffix:m/s")
var speed: float = 0.5

var speed_modifier: float = 1.0

@export_range(1.0, 10.0, 0.2, "or_greater", "suffix:m/s²")
var acceleration: float = 10.0

@export_range(0.5, 5.0, 0.25)
var turn_speed: float = 3.0

var turn_modifier: float = 1.0

var is_moving: bool:
	set(val):
		if is_moving == val: return
		is_moving = val
		emit_signal(&"move_started" if val else &"move_ended")
		if debug_mesh: 
			debug_mesh.visible = is_moving

var target_position: Vector3: set = set_target_position
var target_direction: Vector3: set = set_target_direction

var debug_mesh: Sprite3D

func _ready() -> void:
	$BodyMesh.mesh = $BodyMesh.mesh.duplicate(true)
	$BodyMesh.mesh.changed.connect(update_mesh)
	update_mesh()
	
	if not Engine.is_editor_hint():
		debug_mesh = FlagSprite3D.new()
		add_child(debug_mesh, false, Node.INTERNAL_MODE_FRONT)
		debug_mesh.top_level = true
		debug_mesh.visible = false


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	state_machine.update_physics_process(delta)
	
	if not is_moving:
		velocity = velocity.move_toward(Vector3(0.0, velocity.y, 0.0), acceleration)
	
	move_and_slide()
	


func move_towards_target_and_rotate(delta: float, max_speed: float = speed) -> void:
	move_towards_target(delta, max_speed)
	rotate_towards_velocity(delta)
	is_moving = (not is_at_target())
	

func move_towards_target(delta: float, max_speed: float = speed) -> void:
	if not is_at_target():
		var real_velocity:= get_real_velocity()
		var target_velocity:= position.direction_to(target_position) * max_speed#minf(max_speed, position.distance_to(target_position) * max_speed)
		if target_velocity:
			velocity.x = move_toward(real_velocity.x, target_velocity.x, acceleration * delta)
			velocity.z = move_toward(real_velocity.z, target_velocity.z, acceleration * delta)


func rotate_towards_velocity(delta: float) -> void:
	if abs(velocity.x) + abs(velocity.z) > 0.05:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * turn_speed)


func rotate_towards_position(global_pos: Vector3, duration: float = 1.0) -> void:
	create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT).tween_property(self, ^"global_transform", global_transform.looking_at(global_pos), duration)


func set_target_position(pos: Vector3) -> void:
	target_position = pos
	is_moving = !is_at_target()
	if debug_mesh and is_moving:
		debug_mesh.position = target_position


func stop() -> void:
	target_position = position
	is_moving = false

# TODO: implement...
func set_target_direction(vel: Vector3) -> void:
	target_direction = vel

func is_at_position(pos: Vector3, ignore_y: bool = true) -> bool:
	return ((position - target_position) * Vector3(1.0, 0.0, 1.0)).length() <= TARGET_DISTANCE_THRESHOLD if ignore_y else position.distance_to(pos) <= TARGET_DISTANCE_THRESHOLD

func is_at_target(ignore_y: bool = true) -> bool:
	return is_at_position(target_position)

func update_mesh() -> void:
	return
	$BodyMesh.mesh.material.albedo_color = stats.fur_color if stats else Color.WHITE


func get_speed() -> float:
	return speed


func get_run_speed() -> float:
	# var t: float = inverse_lerp(Stats.MIN_STAT_VALUE, Stats.MAX_STAT_VALUE, get_stat_value(&"run")) 
	return lerpf(RUN_SPEED_MIN, RUN_SPEED_MAX, inverse_lerp(Stats.MIN_STAT_VALUE, Stats.MAX_STAT_VALUE, get_stat_value(&"run")))


func get_stat_value(stat: StringName, default: float = 0.0) -> float:
	return stats.get(stat) if stat in stats else default


func set_stats(val: Stats) -> void:
	if stats and stats.changed.is_connected(_on_stats_changed):
		stats.changed.disconnect(_on_stats_changed)
		
	stats = val
	
	if stats and not stats.changed.is_connected(_on_stats_changed):
		stats.changed.connect(_on_stats_changed)
	
	if is_node_ready():
		_on_stats_changed()

func _on_stats_changed() -> void:
	update_mesh()

func _to_string() -> String:
	return "Pet \"%s\"" % stats.name if stats and stats.name else "Pet-%d" % get_instance_id()

# TESTING
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and Input.is_key_pressed(KEY_PAGEUP):
		if debug_mesh: debug_mesh.visible = !debug_mesh.visible
		get_viewport().set_input_as_handled()

func _get_property_list() -> Array[Dictionary]:
	return [{name = &"mesh", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = &"Mesh", usage = PROPERTY_USAGE_EDITOR}]
	
func _get(property: StringName) -> Variant:
	return $BodyMesh.mesh if is_node_ready() and property == &"mesh" else null

func _set(property: StringName, value: Variant) -> bool:
	if is_node_ready() and property == &"mesh" and value != $BodyMesh.mesh:
		$BodyMesh.mesh = value
		notify_property_list_changed()
		return true
	return false
