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
const POINTS_PER_RANK: int = 3
const SIGNAL_LEVEL: String = "_level_changed"


const FATIGUE_PENALTY_THRESHOLD: int = 32


#@export_storage var stat_format: Dictionary
@export_storage var data: Dictionary:
	set(val): data.merge(val, true)

@export var name: StringName = &"Garfield"

#TODO - Add inhereted stats/props
func _init(_seed: int = randi()) -> void:
	for stat: String in STATS: 
		data[stat] = {}
		add_user_signal(get_signal(stat, "level"))
		for substat: String in SUBSTATS:
			data[stat][substat] = 0
			add_user_signal(get_signal(stat, substat), [{name = "delta", type = TYPE_INT}])
		
		connect(get_signal(stat, "xp"), _on_xp_change.bind(stat))
	
	
	var rng:= RandomNumberGenerator.new()
	rng.seed = _seed
	for s: StringName in STATS:
		set_rank(s, rng.rand_weighted(WEIGHT_RANK))

func add_xp(stat: StringName, amount: int) -> void:
	set_xp(stat, get_xp(stat, 0) + amount)

func add_points(stat: StringName, amount: int) -> void:
	set_points(stat, get_points(stat, 0) + amount)

func GET(stat: StringName, substat: StringName, default: int) -> int:
	return data.get(stat, {}).get(substat, default)

func SET(stat: StringName, substat: StringName, value: int) -> void:
	if stat not in STATS: 
		printerr("'%s' is not a valid stat." % stat)
		return
	if substat not in SUBSTATS:
		printerr("'%s' is not a valid substat." % substat)
		return
	
	var delta: int = value - GET(stat, substat, 0)
	data[stat][substat] = value
	emit_signal(get_signal(stat, substat), delta)


func _on_xp_change(delta: int, stat: StringName,) -> void:
	var new_xp: int = get_xp(stat, 0)
	var level_delta: int = xp_to_level(new_xp) - xp_to_level(new_xp - delta)
	for i: int in level_delta:
		on_level_up(stat)

func on_level_up(stat: StringName) -> void:
	var level_points: int = roll_level_points(get_rank(stat))
	add_points(stat, level_points)
	emit_signal(get_signal(stat, "level"), level_points)

func roll_level_points(rank: int) -> int:
	return roundi((POINTS_PER_RANK * rank + randi_range(11, 15)) * get_level_penalty())

func get_level_penalty() -> float:
	# TODO: Ease?
	return clampf((get_stress() * 1.0 + get_fatigue() * 3 - 30.0)/ 165.0,0.0, 0.8)

func get_rank(stat: StringName, default: int = 0) -> int:
	return GET(stat, &"rank", default)
func get_xp(stat: StringName, default: int = 0) -> int:
	return GET(stat, &"xp", default)
func get_points(stat: StringName, default: int = 0) -> int:
	return GET(stat, &"points", default)

func set_xp(stat: StringName, value: int = 0) -> void:
	SET(stat, &"xp", clampi(value, 0, MAX_LEVEL * XP_PER_LEVEL))
func set_rank(stat: StringName, value: int) -> void:
	SET(stat, &"rank", clampi(value, 0, RANKS.size() - 1))
func set_points(stat: StringName, value: int) -> void:
	SET(stat, &"points", clampi(value, 0, MAX_POINTS))

func get_life() -> int:
	return GET(&"life", &"points", 0)
func get_hunger() -> int:
	return GET(&"hunger", &"points", 0)
func get_fatigue() -> int:
	return GET(&"fatigue", &"points", 0)
func get_stress() -> int:
	return GET(&"stress", &"points", 0)

func set_life(val: int) -> void:
	SET(&"life", &"points", clampi(val, 0, 100))
func set_hunger(val: int) -> void:
	SET(&"hunger", &"points", clampi(val, 0, 100))
func set_fatigue(val: int) -> void:
	SET(&"fatigue", &"points", clampi(val, 0, 100))
func set_stress(val: int) -> void:
	SET(&"stress", &"points", clampi(val, 0, 100))


func get_level(stat: StringName, default: int = 0) -> int:
	return xp_to_level(get_xp(stat, default * XP_PER_LEVEL))
func xp_to_level(xp: int) -> int:
	return xp / XP_PER_LEVEL
func get_level_progress(stat: StringName, default: int = 0) -> int:
	return get_xp(stat) % XP_PER_LEVEL
func get_grade(stat: StringName) -> String:
	return RANKS[get_rank(stat)]


func get_signal(stat: String, substat: String = "") -> StringName:
	return StringName("%s_%s_changed" % [stat, substat]) if substat else stat + "_changed"
func is_connected_signal(stat: String, substat: String, method: Callable) -> bool:
	return is_connected(get_signal(stat, substat), method) if has_signal(get_signal(stat, substat)) else false
func connect_signal(stat: String, substat: String, method: Callable) -> int:
	if Engine.is_editor_hint() and not has_signal(get_signal(stat, substat)): return ERR_DOES_NOT_EXIST
	return connect(get_signal(stat, substat), method)
func disconnect_signal(stat: String, substat: String, method: Callable, flags: ConnectFlags) -> void:
	if is_connected_signal(stat, substat, method): disconnect(get_signal(stat, substat), method)

func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint() or not property.name.contains("/"): return
	
	var slices: PackedStringArray = property.name.split("/", 2)
	match slices[1]:
		"rank": property.hint_string = "0,%s,1,suffix:%s"%[RANKS.size()-1, get_grade(slices[0])]
		"xp": property.hint_string = "0,%s,1,suffix:lv%2.0d" % [(MAX_LEVEL * XP_PER_LEVEL), get_level(slices[0], 0)]
		"points" when slices[0] in ["life", "stress", "fatigue", "hunger"]:
			property.hint_string = "0,100,1,suffix:%"
		"points": 
			property.hint_string = "0,%s" % MAX_POINTS 


func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint(): return []
	var props: Array[Dictionary]
	for i: int in STATS.size():
		for substat : String in SUBSTATS:
				props.push_back({
					name = STATS[i] + "/" + substat, 
					type = TYPE_INT, 
					hint = PROPERTY_HINT_RANGE, 
					hint_string = "0,9999,1,or_less,or_greater", 
					usage = PROPERTY_USAGE_DEFAULT
				})
	return props


func _set(property: StringName, value: Variant) -> bool:
	if property.contains("/") and property.get_slice("/", 0) in STATS:
		SET(property.get_slice("/", 0), property.get_slice("/", 1), value)
		notify_property_list_changed()
		return true
	return false

func _get(property: StringName) -> Variant:
	return data.get(property.get_slice("/", 0), {}).get(property.get_slice("/", 1))
