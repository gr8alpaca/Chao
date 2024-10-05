@tool
class_name Stats extends Resource

@export var name: StringName = &""

@export var life: float = 100.0
var current_life: float = 100.0

@export var stamina: float = 100.0
var current_stamina: float = 100.0

@export var speed: float = 10.0
@export var power: float = 10.0
@export var finesse: float = 10.0


var modifiers: Dictionary


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	for prop: String in modifiers.keys():
		props.append({name = prop, type = TYPE_FLOAT, usage = PROPERTY_USAGE_EDITOR})
	return props


func _get(property: StringName) -> Variant:
	match property:
		&"speed":
			return speed * modifiers.get("speed", 0.0) + speed
		&"power":
			return power * modifiers.get("power", 0.0) + power
		&"finesse":
			return finesse * modifiers.get("finesse", 0.0) + finesse
	return null
