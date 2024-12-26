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


var target_position: Vector3: set = set_target_position
var target_direction: Vector3: set = set_target_direction

var debug_mesh: Sprite3D

func _ready() -> void:
	$BodyMesh.mesh.changed.connect(update_mesh)
	
	update_mesh()
	
	if not Engine.is_editor_hint():
		debug_mesh = FlagSprite3D.new()
		add_child(debug_mesh, false, Node.INTERNAL_MODE_FRONT)
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	state_machine.update_physics_process(delta)
	return
	
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#
	#
	#var xz_dir: Vector3 = Vector3.ZERO
	#var real_velocity := get_real_velocity()
#
	#if is_moving:
		#rotation = rotation.move_toward(Vector3(0.0, rotation.y, 0.0), delta)
		#
		#xz_dir = Vector3(global_position.x, 0, global_position.z).direction_to(Vector3(target_position.x, 0, target_position.z))
		#var xz_vel := xz_dir * speed * speed_modifier
		#
		#velocity.x = move_toward(real_velocity.x, xz_vel.x, acceleration * delta)
		#velocity.z = move_toward(real_velocity.z, xz_vel.z, acceleration * delta)
		#
		#if global_position.distance_to(target_position) > TARGET_DISTANCE_THRESHOLD:
			#global_rotation.y = lerp_angle(global_rotation.y, Vector2(-xz_dir.z, -xz_dir.x).angle(), delta * turn_speed)
		#else:
			#is_moving = false
#
	#else:
		#velocity.x = move_toward(real_velocity.x, 0, speed)
		#velocity.z = move_toward(real_velocity.z, 0, speed)

	# print("Floor: %s\t%01.02v\t%01.02v" % [is_on_floor(), velocity, xz_dir])
	move_and_slide()

#
#func _process(delta: float) -> void:
	#state_machine.update_process(delta)


func rotate_towards_position(global_pos: Vector3, duration: float = 1.0) -> void:
	create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT).tween_property(self, ^"global_transform", global_transform.looking_at(global_pos), duration)


func move_to_point(pos: Vector3) -> void:
	target_position = pos
	is_moving = true


func set_target_position(pos: Vector3) -> void:
	target_position = pos
	if debug_mesh and is_inside_tree():
		debug_mesh.global_position = target_position


# TODO: implement...
func set_target_direction(vel: Vector3) -> void:
	target_direction = vel


func get_speed() -> float:
	# if not stats: return speed
	# var speed_value: float = stats.speed if stats else speed
	# var t: float = inverse_lerp(Stats.MIN_STAT_VALUE, Stats.MAX_STAT_VALUE, get_stat_value(&"run")) 
	# lerpf(RUN_SPEED_MIN, RUN_SPEED_MAX, )
	return speed


func get_run_speed() -> float:
	# var t: float = inverse_lerp(Stats.MIN_STAT_VALUE, Stats.MAX_STAT_VALUE, get_stat_value(&"run")) 
	return lerpf(RUN_SPEED_MIN, RUN_SPEED_MAX, inverse_lerp(Stats.MIN_STAT_VALUE, Stats.MAX_STAT_VALUE, get_stat_value(&"run")))


func get_stat_value(stat: StringName, default: float = 0.0) -> float:
	return stats.get(stat) if stat in stats else default

func update_mesh() -> void:
	$BodyMesh.mesh.material.albedo_color = stats.fur_color if stats else Color.WHITE


func set_stats(val: Stats) -> void:
	stats = val
	if stats and not stats.changed.is_connected(_on_stats_changed):
		stats.changed.connect(_on_stats_changed)
		
	if is_node_ready():
		_on_stats_changed()


func _on_stats_changed() -> void:
	speed = 0.1 if not stats else lerpf(RUN_SPEED_MIN, RUN_SPEED_MAX, inverse_lerp(0, Stats.MAX_STAT_VALUE, stats.run))
	update_mesh()

func _to_string() -> String:
	return "Pet \"%s\"" % stats.name if stats and stats.name else "Pet-%d" % get_instance_id()

# TESTING
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and Input.is_key_pressed(KEY_PAGEUP):
		if debug_mesh: debug_mesh.visible = !debug_mesh.visible
		get_viewport().set_input_as_handled()
