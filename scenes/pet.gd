@tool
class_name Pet extends CharacterBody3D

signal move_started
signal move_ended

@export var debug_mesh: MeshInstance3D

@export var stats: Stats
# @export var ray: RayCast3D

@export_range(1.0, 10.0, 0.2, "or_greater", "suffix:m/s")
var speed: float = 5.0

var speed_modifier: float = 1.0

@export_range(1.0, 10.0, 0.2, "or_greater", "suffix:m/s²")
var acceleration: float = 10.0


@export_range(0.5, 5.0, 0.25)
var turn_speed: float = 3.0

var turn_modifier: float = 1.0

enum {PET_STATE_NONE, PET_STATE_IDLE,  PET_STATE_RACE}

var state: int = PET_STATE_NONE: set = set_state

var is_moving: bool:
	set(val):
		if is_moving == val: return
		is_moving = val
		emit_signal("move_started" if val else "move_ended")
		if not is_moving and state == PET_STATE_IDLE:
			random_delay()

var target_position: Vector3: set = set_target_position
var path_points: PackedVector3Array



func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var xz_dir: Vector3 = Vector3.ZERO

	if state != PET_STATE_NONE:
		rotation = rotation.move_toward(Vector3(0,rotation.y, 0), delta)

	var real_velocity:= get_real_velocity()

	if is_moving:

		xz_dir = Vector3(global_position.x, 0, global_position.z).direction_to(Vector3(target_position.x, 0, target_position.z))
		var xz_vel := xz_dir * speed * speed_modifier
		
		velocity.x = move_toward(real_velocity.x, xz_vel.x, acceleration * delta)
		velocity.z = move_toward(real_velocity.z, xz_vel.z, acceleration * delta)
		
		if global_position.distance_to(target_position) > 0.1:
			global_rotation.y = lerp_angle(global_rotation.y, Vector2(-xz_dir.z, -xz_dir.x).angle(), delta * turn_speed)
		else:
			is_moving = false

	else:
		velocity.x = move_toward(real_velocity.x, 0, speed)
		velocity.z = move_toward(real_velocity.z, 0, speed)

		# var dir: Vector3 = global_position.direction_to(target_position)
		
		
	# print("Floor: %s\t%01.02v\t%01.02v" % [is_on_floor(), velocity, xz_dir])
	move_and_slide()


func set_state(new_state: int) -> void:

	speed_modifier = 1.0

	match new_state:
		PET_STATE_NONE:
			target_position = global_position
			is_moving = false

		PET_STATE_IDLE:
			state = new_state
			wander_random()
		

	state = new_state

const MAX_WANDER_DISTANCE: float = 5.0



func random_delay() -> void:
	var MIN_DELAY: float = 1.0
	var MAX_DELAY: float = 5.0
	create_tween().tween_callback(wander_random).set_delay(lerpf(MIN_DELAY, MAX_DELAY, randf()))


func wander_random() -> void:
	if state != PET_STATE_IDLE: return
	speed_modifier = 0.1
	target_position = get_random_point()
	if not move_ended.is_connected(random_delay):
		move_ended.connect(random_delay, CONNECT_ONE_SHOT)


func look_camera() -> void:
	const LOOK_TIME: float = 0.5
	state = PET_STATE_NONE
	rotate_towards_position(get_viewport().get_camera_3d().global_position, LOOK_TIME)


func rotate_towards_position(global_pos: Vector3, duration: float = 1.0) -> Tween:
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, ^"global_transform", global_transform.looking_at(global_pos), duration)
	return tw


func get_random_point(max_dist: float = MAX_WANDER_DISTANCE, origin:=Vector3.ZERO) -> Vector3:
	return Vector3(randf_range(-MAX_WANDER_DISTANCE, MAX_WANDER_DISTANCE) + origin.x, position.y, randf_range(-MAX_WANDER_DISTANCE, MAX_WANDER_DISTANCE) + origin.z)

func set_target_position(pos: Vector3) -> void:
	printt("setting target position", pos)
	target_position = pos
	is_moving = (global_position.distance_to(target_position) > 0.1)

	if debug_mesh:
		debug_mesh.global_position = target_position


func get_speed() -> float:
	return speed


func get_path_distance(path: PackedVector3Array = path_points) -> float:
	if path.is_empty(): return 0.0
	var accum: float = global_position.distance_to(path[0])
	for i: int in path.size() - 1:
		accum += path[i].distance_to(path[i + 1])
	return accum

func _to_string() -> String:
	return "Pet \"%\"" % stats.name if stats and stats.name else "Pet-%d" % get_instance_id()