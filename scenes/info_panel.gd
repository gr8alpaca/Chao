@tool
class_name InfoPanel extends Panel


@export var pet: Pet:
	set(val):
		pet = val
		stats = pet.stats


@export var stats: Stats:
	set(val):
		stats = val


func _ready() -> void:
	visible = false

func open() -> void:
	pass
func close() -> void:
	pass