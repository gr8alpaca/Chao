@tool
class_name ActivityXP extends Object

const STAT_MIN_DELTA: int = 3
const STAT_MAX_DELTA: int = 6

const GRADE_TABLE: Dictionary = \
{
	"S": [1.0, 1.0],
	"A": [1.0, 1.0],
	"B": [1.0, 1.0],
	"C": [1.0, 1.0],
	"D": [1.0, 1.0],
	"E": [1.0, 1.0],
}


static func roll_exercise(exercise: Exercise) -> Dictionary:
	var deltas: Dictionary
	for stat: String in exercise.get_stat_changes():
		var base: int = randi_range(STAT_MIN_DELTA * exercise[stat], STAT_MAX_DELTA * exercise[stat])
		#var rank_bonus: int = randi_range()
		deltas[stat] = base
	return deltas


static func roll_rank_bonus(rank: float) -> Dictionary:
	const GRADE_TABLE: Dictionary = {
		"S": [1.0, 1.0],
		"A": [1.0, 1.0],
		"B": [1.0, 1.0],
		"C": [1.0, 1.0],
		"D": [1.0, 1.0],
		"E": [1.0, 1.0],
	}
	
	var t: float = inverse_lerp(Stats.MIN_RANK, Stats.MAX_RANK, rank)
	const MIN_RANK: int = 10
	const MAX_RANK: int = 34
	return {}
