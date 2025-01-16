@tool
class_name ActivityResult extends RefCounted

const FATIGUE_PER_POINT: int = 11
const FATIGUE_VARIANCE: int = 3

const XP_DELTA_MAX: int = 2

const FATIGUE_PENALTY_MIN: int = 16

# TODO
enum {NONE, SUCCESS, FAILURE, CHEAT}

var deltas: Dictionary

func _init(activity: Activity, stats: Stats) -> void:
	self.stats = stats
	deltas[&"fatigue"] = {points = _roll_fatigue(activity, stats)}
	for stat_name: StringName in activity.get_stat_changes():
		deltas[stat_name] = {xp = _roll_stat(stat_name, activity, stats)}

func _roll_fatigue(activity: Activity, stats: Stats) -> int:
	var base_delta: int = activity.fatigue * FATIGUE_PER_POINT 
	var roll : int = randi() % (FATIGUE_VARIANCE * abs(activity.fatigue) * 2) - (FATIGUE_VARIANCE * abs(activity.fatigue))
	var rest_bonus: int = -stats.get_fatigue() / 2 if activity.name == &"rest" else 0
	return base_delta + roll + rest_bonus

func _roll_stat(name: StringName, activity: Activity, stats: Stats) -> int:
	assert(activity.get_delta(name, 0) != 0, "Empty Stat Rolled!")
	var life_index_penalty: float = 1.0 - minf(0.8, ease(stats.get_life_index_ratio(), 1.4))
	var base_delta: int = activity._get_base_xp_change(activity.get_delta(name, 0)) 
	var roll: int = randi_range(-abs(activity.get_delta(name, 0)), abs(activity.get_delta(name, 0)))
	return base_delta * life_index_penalty + activity.get_delta(name, 0)

func apply(stats: Stats) -> void:
	for stat: StringName in deltas:
		for substat: StringName in deltas[stat]:
			stats.SET(stat, substat, stats.GET(stat, substat, 0) + deltas[stat][substat])

func unapply(stats: Stats) -> void:
	for stat: StringName in deltas:
		for substat: StringName in deltas[stat]:
			stats.SET(stat, substat, stats.GET(stat, substat, 0) - deltas[stat][substat])
