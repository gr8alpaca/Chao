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

enum {PET_STATE_NONE, PET_STATE_IDLE, PET_STATE_RACE}


var is_moving: bool:
	set(val):
		if is_moving == val: return
		is_moving = val
		emit_signal("move_started" if val else "move_ended")
		# if not is_moving and state == PET_STATE_IDLE:
		# 	random_delay()

var target_position: Vector3: set = set_target_position
var path_points: PackedVector3Array


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var xz_dir: Vector3 = Vector3.ZERO
	var real_velocity := get_real_velocity()

	if is_moving:
		rotation = rotation.move_toward(Vector3(0.0, rotation.y, 0.0), delta)

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


func rotate_towards_position(global_pos: Vector3, duration: float = 1.0) -> void:
	create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT).tween_property(self, ^"global_transform", global_transform.looking_at(global_pos), duration)


func move_to_point(pos: Vector3) -> void:
	target_position = pos
	is_moving = true


func set_target_position(pos: Vector3) -> void:
	target_position = pos
	if debug_mesh:
		debug_mesh.global_position = target_position


func get_speed() -> float:
	return speed


func _to_string() -> String:
	return "Pet \"%s\"" % stats.name if stats and stats.name else "Pet-%d" % get_instance_id()