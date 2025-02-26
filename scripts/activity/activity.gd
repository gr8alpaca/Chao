@tool
class_name Activity extends Resource
## Anything that fills a week slot in the schedule

enum { NONE, SUCCESS, FAILURE, }
const XP_DELTA_RANGES:Dictionary = {
	NONE : Vector2i(0,0),
	SUCCESS : Vector2i(6,9),
	FAILURE : Vector2i(1,3),
	#CHEAT TODO
}

const FATIGUE_PER_POINT: int = 11
const FATIGUE_VARIANCE: int = 3




@export var name: StringName = &"Invalid":
	set(val):
		name = val
		resource_name = val

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var fatigue: int = 1

@export var scene: PackedScene

@export var drag_unicode_code: int = 128170:
	set(val):
		drag_unicode_code = val
		symbol = char(val)
		notify_property_list_changed()


@export_custom(0, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT)
var symbol: String


func get_result(rand: PackedInt64Array, stats: Stats = null) -> ActivityResult:
	var result: ActivityResult = ActivityResult.new()
	result.outcome = roll_outcome(rand, stats)
	result.fatigue_delta = roll_fatigue(result.outcome, rand, stats)
	result.deltas = roll_deltas(result.outcome, rand, stats)
	return result

func roll_outcome(rand: PackedInt64Array, stats: Stats = null) -> int:
	return NONE

func roll_fatigue(outcome_status: int, rand: PackedInt64Array, stats: Stats = null) -> int:
	rand = Util.rand_advance(rand)
	var base_delta: int = fatigue * FATIGUE_PER_POINT 
	var variance: int = (rand[0] % (FATIGUE_VARIANCE * abs(fatigue) * 2 + 1)) - FATIGUE_VARIANCE * abs(fatigue)
	# TODO - add to rest
	var rest_bonus: int = -stats.get_fatigue() / 2 if stats and name == &"rest" else 0
	return base_delta + variance + rest_bonus

func roll_deltas(outcome_status: int, rand: PackedInt64Array, stats: Stats = null) -> Dictionary[String, int]:
	var dict: Dictionary[String, int]
	for stat: StringName in get_stat_changes():
		dict[stat] = roll_stat_delta(stat, outcome_status, Util.rand_advance(rand)[0], stats)
	return dict

func roll_stat_delta(stat_name: StringName, outcome: int, rand: int, stats: Stats = null, ) -> int:
	assert(outcome < XP_DELTA_RANGES.size())
	assert(get(stat_name) != null)
	return (XP_DELTA_RANGES[outcome][0] + (rand % (XP_DELTA_RANGES[outcome][1] - XP_DELTA_RANGES[outcome][0]))) * int(get(stat_name))

func get_stat_changes() -> PackedStringArray:
	return PackedStringArray()

func has_scene() -> bool:
	return scene != null

func get_scene() -> PackedScene:
	return scene

func get_drag_preview() -> String:
	return symbol + " " + name
