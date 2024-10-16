@tool
class_name Waypoint extends Area3D
const GROUP: StringName = &"Waypoint"
# const DEBUG_MATERIAL: StandardMaterial3D = preload("res://resources/debug_material.tres")
const META_NEXT: StringName = &"next_waypoint"

@export var next: Node3D

@export var dimensions: Vector3 = Vector3(0.2, 0.5, 2.0):
	set(val):
		dimensions = val
		update_area()

@export var debug_mode: bool: set = set_debug_mode

@export var foo: bool:
	set(val):
		if not val: return
		print("Global Position: ", global_position)
		print(to_global(Vector3.FORWARD))

var debug_mesh: MeshInstance3D = MeshInstance3D.new()
var collision_shape: CollisionShape3D = CollisionShape3D.new()


func _init() -> void:
	add_to_group(GROUP)

	body_entered.connect(_on_body_entered)
	

	add_child(collision_shape, false, INTERNAL_MODE_BACK)
	add_child(debug_mesh, false, INTERNAL_MODE_FRONT)
	collision_shape.shape = BoxShape3D.new()
	update_area()


func _on_body_entered(body: Node3D) -> void:
	if not body is Pet: return
	body.set_meta(&"next_waypoint", next)
	if next:
		body.target_position = next.get_path_point()
	printt("Pet entered: ", body.name, body.target_position)

func get_race_path() -> PackedVector3Array:
	var path: PackedVector3Array
	var current_wp: Waypoint = self
	
	while current_wp:
		path.push_back(current_wp.get_path_point())
		current_wp = current_wp.next

	return path


func get_path_point() -> Vector3:
	var min_pos: Vector3 = to_global(Vector3.FORWARD * dimensions.z / 2.0)
	var max_pos: Vector3 = to_global(Vector3.BACK * dimensions.z / 2.0)
	return min_pos.lerp(max_pos, randf())
	

func update_area() -> void:
	collision_shape.shape.size = dimensions
	debug_mesh.position.y = dimensions.y / 2
	collision_shape.position.y = dimensions.y / 2
	debug_mesh.mesh = collision_shape.shape.get_debug_mesh()

	# debug_mesh.mesh.material = preload("res://resources/debug_material.tres")


func set_debug_mode(val: bool) -> void:
	debug_mode = val
	debug_mesh.visible = debug_mode


func _on_waypoint_order_changed(parent: Node) -> void:
	if parent.get_child_count() - 1 == get_index(): return
	var node: Node = parent.get_child(get_index() + 1)
	

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			var parent: Node = get_parent()
			parent.child_order_changed.connect(_on_waypoint_order_changed.bind(parent), CONNECT_DEFERRED)
		
		NOTIFICATION_EXIT_TREE when get_parent().child_order_changed.is_connected(_on_waypoint_order_changed):
			get_parent().child_order_changed.disconnect(_on_waypoint_order_changed)
