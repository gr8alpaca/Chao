@tool
class_name Stats extends Resource

## Rank affects the growth of skills points on level upon
const RANKS:PackedStringArray =         [ "E",  "D",  "C",   "B", "A",  "S",] 
const WEIGHT_RANK: PackedFloat32Array = [0.24, 0.37, 0.17, 0.13, 0.07, 0.02,]

const STAT_VISIBLE_COUNT: int = 5
const STATS: PackedStringArray = [
	"stamina",
	"run", 
	"swim", 
	"fly", 
	"power",
	"life",
	"hunger",
	"fatigue",
	"stress",
	]

const SUBSTATS: PackedStringArray = [
	"rank", 
	"xp", 
	"points",
	]

const MAX_LEVEL: int = 99
const XP_PER_LEVEL: int = 8

const MAX_POINTS: int = 9999

@export_storage var data: Dictionary

@export var name: StringName = &"Garfield"


#TODO - Add inhereted stats/props


func _init(_seed: int = randi()) -> void:
	for stat: String in STATS: 
		data[stat] = {}
		for substat: String in SUBSTATS:
			data[stat][substat] = 0
			add_user_signal(get_signal(stat, substat), [{name = "new_value", type = TYPE_INT}])
	
	var rng:= RandomNumberGenerator.new()
	rng.seed = _seed
	for s: StringName in STATS:
		set_rank(s, rng.rand_weighted(WEIGHT_RANK))

func add_xp(stat: StringName, amount: int = 0) -> void:
	set_xp(stat, get_xp(stat, 0) + amount)

func GET(stat: StringName, substat: StringName, default: int) -> int:
	return data[stat][substat]
func SET(stat: StringName, substat: StringName, value: int) -> void:
	data[stat][substat] = value
	emit_signal(get_signal(stat, substat), value)

func get_rank(stat: StringName, default: int = 0) -> int:
	return GET(stat, &"rank", default)
func get_xp(stat: StringName, default: int = 0) -> int:
	return GET(stat, &"xp", default)
func get_points(stat: StringName, default: int = 0) -> int:
	return GET(stat, &"points", default)

func set_rank(stat: StringName, value: int) -> void:
	SET(stat, &"rank", clampi(value, 0, RANKS.size() - 1))
func set_xp(stat: StringName, value: int = 0) -> void:
	#TODO Signal level change...
	SET(stat, &"xp", clampi(value, 0, MAX_LEVEL * XP_PER_LEVEL))
func set_points(stat: StringName, value: int) -> void:
	SET(stat, &"points", clampi(value, 0, MAX_POINTS))


func get_level(stat: StringName, default: int = 0) -> int:
	return get_xp(stat) / XP_PER_LEVEL

func get_level_progress(stat: StringName, default: int = 0) -> int:
	return get_xp(stat) % XP_PER_LEVEL

func get_grade(stat: StringName) -> String:
	return RANKS[get_rank(stat)]


func get_signal(stat: String, substat: String) -> String:
	return "%s_%s_changed" % [stat, substat]
func is_connected_signal(stat: String, substat: String, method: Callable) -> bool:
	return is_connected(get_signal(stat, substat), method)
func connect_signal(stat: String, substat: String, method: Callable) -> int:
	return connect(get_signal(stat, substat), method)
func disconnect_signal(stat: String, substat: String, method: Callable, flags: ConnectFlags) -> int:
	return connect(get_signal(stat, substat), method, flags)


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint() or not property.name.contains("/"): return
	match property.name.get_slice("/", 1):
		"rank": property.hint_string = "0,%s,1,suffix:%s"%[RANKS.size()-1,get_grade(property.name.get_slice("/", 0))]
		"xp": property.hint_string = "0,%s" % (MAX_LEVEL * XP_PER_LEVEL)
		"points": property.hint_string = "0,%s" % MAX_POINTS
		"life", "stress", "fatigue", "hunger": 
			property.merge({hint_string = "0,100,1,suffix:%", usage = PROPERTY_USAGE_DEFAULT,}, true)


func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint(): return []
	var props: Array[Dictionary]
	
	for stat: String in STATS: 
		for substat : String in SUBSTATS:
			props.push_back({
				name = stat + "/" + substat, 
				type = TYPE_INT, 
				hint = PROPERTY_HINT_RANGE, 
				hint_string = "0,9999,1,or_less,or_greater", 
				usage = PROPERTY_USAGE_DEFAULT
			})
	return props

func _set(property: StringName, value: Variant) -> bool:
	if not property.contains("/"): return false
	SET(property.get_slice("/", 0), property.get_slice("/", 1), value)
	notify_property_list_changed()
	return true

func _get(property: StringName) -> Variant:
	return data.get(property.get_slice("/", 0), {}).get(property.get_slice("/", 1))
