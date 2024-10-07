@tool
class_name Stats extends Resource

const VISIBLE_STATS: PackedStringArray = ["run", "swim", "fly", "power"]
const MIN_RANK: int = 10
const MAX_RANK: int = 34

const MAX_LEVEL: int = 8

signal level_changed(stat_name: StringName, )


@export var name: StringName = &""

#region Hidden

@export_range(0.0, 100.0, 1.0, "suffix:%")
var life: float = 100.0:
	set(val):
		life = val
		changed.emit()


@export_range(0.0, 100.0, 1.0, "suffix:%")
var hunger: float = 0.0:
	set(val):
		hunger = val
		changed.emit()


@export_range(0.0, 100.0, 1.0, "suffix:%")
var energy: float = 100.0:
	set(val):
		energy = val
		changed.emit()


@export_range(0.0, 100.0, 1.0, "suffix:%")
var stress: float = 0.00:
	set(val):
		stress = val
		changed.emit()


#endregion Hidden

#region Visible


@export_range(0.0, 999.9, 5.0, "hide_slider")
var run: float = 10.0:
	set(val):
		run = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var fly: float = 10.0:
	set(val):
		fly = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var swim: float = 10.0:
	set(val):
		swim = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var power: float = 10.0:
	set(val):
		power = val
		changed.emit()


#endregion Visible

#region Rank

@export_storage
var ranks: Dictionary

func get_rank(stat: StringName, default: float = MIN_RANK) -> float:
	return ranks.get(stat, default)

const RANK_THRESHOLDS: Dictionary = {S = 30.0, A = 26.0, B = 22.0, C = 18.0, D = 14.0, E = 10.0}
func get_grade(stat: StringName) -> String:
	var rank: float = get_rank(stat)
	if rank > 30.0: return "S"
	if rank > 26.0: return "A"
	if rank > 22.0: return "B"
	if rank > 18.0: return "C"
	if rank > 14.0: return "D"
	return "E"

#endregion Rank

#region Level

@export_storage
var levels: Dictionary

func get_level(stat: StringName, default: float = 0.0) -> int:
	return levels.get(stat, default)

func set_level(stat: StringName, val: int) -> void:
	levels[stat] = val
	
#endregion Level


#region Properties


func _init(inhereted_ranks: Dictionary = {}) -> void:
	for s: StringName in VISIBLE_STATS:
		ranks[s] = inhereted_ranks.get(s, roll_rank())


func roll_rank() -> float:
	# const RANKS:PackedStringArray = ["S", "A", "B", "C", "D", "E"]
	const RANK_MIN: PackedFloat32Array = [30.0, 26.0, 22.0, 18.0, 14.0, 10.0]
	const RANK_WEIGHTS: PackedFloat32Array = [0.02, 0.07, 0.13, 0.24, 0.37, 0.17]
	var roll: float = randf()

	var index: int = 0

	while index < RANK_WEIGHTS.size() and roll > RANK_WEIGHTS[index]:
		roll -= RANK_WEIGHTS[index]
		index += 1

	return randf_range(RANK_MIN[index], RANK_MIN[index] + 4.0)


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]


	props.append({
		name="Ranks", type=TYPE_NIL,
		hint_string="rank",
		usage=PROPERTY_USAGE_CATEGORY
	})

	for stat: StringName in ranks.keys():
		props.append({
			name="rank_" + stat,
			type=TYPE_FLOAT,
			hint=PROPERTY_HINT_RANGE,
			hint_string="{min}, {max}, 1, suffix: {grade} ".format({min=MIN_RANK, max=MAX_RANK, grade=get_grade(stat)}),
			usage=PROPERTY_USAGE_DEFAULT,
		})

	props.append({
		name="Levels", type=TYPE_NIL,
		hint_string="level",
		usage=PROPERTY_USAGE_CATEGORY
	})

	for stat: StringName in levels.keys():
		props.append({
			name="level_" + stat,
			type=TYPE_INT,
			hint=PROPERTY_HINT_RANGE,
			hint_string="0, {max}, 1, suffix:/ {max} ".format({max=MAX_LEVEL}),
			usage=PROPERTY_USAGE_DEFAULT,
		})


	return props


func _get(property: StringName) -> Variant:

	if "level_" in property:
		return get_level(property.trim_prefix("level_"))

	if "rank_" in property:
		return get_rank(property.trim_prefix("rank_"))

	
	return null


func _set(property: StringName, value: Variant) -> bool:
	if "level_" in property:
		set_level(property.trim_prefix("level_"), value)
		notify_property_list_changed()
		return true

	return false


func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"run", &"fly", &"swim":
			property.hint = PROPERTY_HINT_RANGE
			property.hint_string = "0.0, 999.9, 1.0, hide_slider, suffix: " + get_grade(property.name)
			property.usage |= PROPERTY_USAGE_READ_ONLY

#endregion Properties

func _to_string() -> String:
	return "Stats-%s" % (name if name else get_instance_id())