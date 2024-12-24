@tool
class_name ActivityXP extends Object

const STAT_MIN_DELTA: int = 3
const STAT_MAX_DELTA: int = 6

static func roll_exercise(exercise: Exercise) -> Dictionary:
	var deltas: Dictionary
	for stat: String in exercise.get_stat_changes():
		deltas[stat] = randi_range(STAT_MIN_DELTA * exercise[stat], STAT_MAX_DELTA * exercise[stat])
	return deltas
