# 
@tool
class_name PetStateMoveToPosition extends PetState

# signal transition_requested(new_state: String)
# signal lock_state(set_locked: bool)

# var name

# var pet: Pet : set = set_pet
@export var debug: bool = true
var target: Vector3

func _init() -> void:
	super(&"move_to_position")

func enter() -> void:
	pass

func exit() -> void:
	pass
	

func update_process(delta: float) -> void:
	pass

func update_physics_process(delta: float) -> void:
	pass
	#var xz_dir: Vector3 = Vector3.ZERO
	#var real_velocity := get_real_velocity()
	
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
	
	#else:
		#velocity.x = move_toward(real_velocity.x, 0, speed)
		#velocity.z = move_toward(real_velocity.z, 0, speed)

	# print("Floor: %s\t%01.02v\t%01.02v" % [is_on_floor(), velocity, xz_dir])


func on_input(event: InputEvent) -> void:
	pass


func on_unhandled_input(event: InputEvent) -> void:
	pass


func set_pet(val: Pet) -> void:
	super(val)

func set_stats(val: Stats) -> void:
	super(val)
