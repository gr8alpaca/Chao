@tool
class_name Schedule extends Node
const GROUP: StringName = &"Schedule"

var date: int = 0 # Represents Year-Month-Week
var logs: Array[Dictionary] # Log of action taken and result for week

var schedule: Array

func _init() -> void:
	add_to_group(GROUP)
