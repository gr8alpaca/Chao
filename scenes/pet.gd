@tool
class_name Pet extends CharacterBody3D

@export var debug_mesh: MeshInstance3D

@export var stats: Stats
# @export var ray: RayCast3D

@export var speed: float = 0.2

var target_position: Vector3: set = set_target_position

var gravity_vector: Vector3 = ProjectSettings.get_setting("physics/2d/default_gravity", 9.8) * Vector3.DOWN

@export_custom(0, "", PROPERTY_USAGE_EDITOR) 
var test_look_position: Vector3:
	set(val):
		test_look_position = val
		if test_look_position:
			look_at(test_look_position,)
		else:
			rotation = Vector3.ZERO

# func _ready() -> void:
# 	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if global_position != target_position:
		var dir:= global_position.direction_to(target_position)
		velocity = dir * speed * Vector3(1, 0, 1)
		# var target_delta: Vector3 = target_position - global_position
		# target_delta.y = 
		look_at(position + velocity)
		# Vector3.BACK
	else:
		velocity = Vector3.ZERO
		# var dir: Vector3 = global_position.direction_to(target_position)
		
		

	if not is_on_floor():
		velocity += (gravity_vector * delta)

	print(velocity)
	move_and_slide()


func set_target_position(pos: Vector3) -> void:
	printt("setting target position", pos)
	target_position = pos
	if debug_mesh:
		debug_mesh.global_position = target_position

