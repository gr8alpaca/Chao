@tool
class_name Activity extends Resource
### Anything that fills a week slot in the schedule

enum { NONE, SUCCESS, FAILURE, }

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
	result.fatigue_delta = roll_fatigue(rand, stats)
	
	return result

func roll_fatigue(rand: PackedInt64Array, stats: Stats = null) -> int:
	rand = Util.rand_advance(rand)
	var base_delta: int = fatigue * FATIGUE_PER_POINT 
	var variance: int = (rand[0] % (FATIGUE_VARIANCE * abs(fatigue) * 2 + 1)) - FATIGUE_VARIANCE * abs(fatigue)
	# TODO - add to rest
	#var rest_bonus: int = -stats.get_fatigue() / 2 if name == &"rest" else 0
	return base_delta + variance

func roll_deltas(rand: PackedInt64Array) -> Dictionary:
	return {}

func get_stat_changes() -> PackedStringArray:
	return PackedStringArray()

func has_scene() -> bool:
	return scene != null

func get_scene() -> PackedScene:
	return scene

func get_drag_preview() -> String:
	return symbol + " " + name
