@tool
class_name Model extends Node3D

@export var material: Material:
	set(val):
		for child in get_children():
			if child is MeshInstance3D:
				child.set_indexed(^"mesh:material", val)
				notify_property_list_changed()
	
	get:
		
		for child in get_children():
			if child is MeshInstance3D: return child.get_indexed(^"mesh:material")
		return null
	
