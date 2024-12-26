@tool
class_name FloorModel extends Node3D

@export var box_dimensions: Vector3: set = set_box_dimension

@export var material: Material: set = set_material, get = get_material


func _init(size: Vector3 = Vector3(1.0, 0.1, 1.0)) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	body.add_child(collision_shape)
	add_child(body)
	
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	add_child(mesh)
	box_dimensions = size


func set_box_dimension(val: Vector3) -> void:
	box_dimensions = val
	var body: StaticBody3D = get_child(0)
	var collision_shape: CollisionShape3D = body.get_child(0)
	var mesh_instance: MeshInstance3D = get_child(1)
	
	collision_shape.shape.size = val
	mesh_instance.mesh.size = val
	body.position.y = -box_dimensions.y/2.0
	mesh_instance.position.y = body.position.y


func set_material(val: Material) -> void:
	get_child(1).mesh.material = val
	notify_property_list_changed()
	
func get_material() -> Material:
	return get_child(1).mesh.material 
	
