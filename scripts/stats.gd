@tool
class_name Stats extends Resource

#TODO signal level_up
signal experience_changed(stat_name: StringName, new_experience_amount: int)

#TODO convert to point values...
const MIN_STAT_VALUE: int = 0
const MAX_STAT_VALUE: int = 9999

const VISIBLE_STATS: PackedStringArray = ["stamina", "run", "swim", "fly", "power"]

## Rank affects the growth of skills points on level upon
enum Rank{E,D,C,B,A}



const MIN_LEVEL: int = 0
const MAX_LEVEL: int = 99

const EXPERIENCE_PER_LEVEL: int = 8
const MAX_EXPERIENCE: int = MAX_LEVEL * EXPERIENCE_PER_LEVEL


@export var name: StringName = &"Garfield"
@export var fur_color: Color = Color.WHITE:
	set(val):
		fur_color = val
		changed.emit()


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
var fatigue: float = 0.0:
	set(val):
		fatigue = val
		changed.emit()


@export_range(0.0, 100.0, 1.0, "suffix:%")
var stress: float = 0.00:
	set(val):
		stress = val
		changed.emit()


#endregion Hidden


#region Skills


@export_range(0.0, 999.9, 5.0, "hide_slider")
var stamina: float = 0.0:
	set(val):
		stamina = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var run: float = 0.0:
	set(val):
		run = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var fly: float = 0.0:
	set(val):
		fly = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var swim: float = 0.0:
	set(val):
		swim = val
		changed.emit()


@export_range(0.0, 999.9, 5.0, "hide_slider")
var power: float = 0.0:
	set(val):
		power = val
		changed.emit()


#endregion Skills

const RANK_WEIGHTS: PackedFloat32Array = [
	0.24, # E
		0.37, # D
			0.17, # C
				0.13, # B
					0.07, # A
						0.02,] # S

func _init(_seed: int = randi()) -> void:
	var rng:= RandomNumberGenerator.new()
	rng.seed = _seed
	for s: StringName in VISIBLE_STATS:
		ranks[s] = rng.rand_weighted(RANK_WEIGHTS)

#region Rank

@export_storage
var ranks: Dictionary = {}

func get_rank(stat: StringName, default: float = Rank.E) -> Rank:
	return ranks.get(stat, default)


func get_grade(stat: StringName) -> String:
	return ["E","D","C","B","A", "S"][ranks[stat]]

#endregion Rank

func get_experience(stat: StringName, default: int = 0) -> int:
	return get(stat) if stat in self else default

func set_experience(stat: StringName, value: int = 0) -> void:
	set(stat, clampi(value, 0, MAX_EXPERIENCE))

func get_level(stat: StringName, default: int = 0) -> int:
	return get_experience(stat) / EXPERIENCE_PER_LEVEL
	
func get_level_progress(stat: StringName, default: int = 0) -> int:
	return get_experience(stat) % EXPERIENCE_PER_LEVEL

func add_experience(stat: StringName, amount: int = 0) -> void:
	set_experience(stat, get_experience(stat, 0) + amount)


#region Properties

#const SIGNAL_EXPERIENCE: String = "_experience_added"
#add_user_signal(s + SIGNAL_EXPERIENCE, [{name = "amount", type = TYPE_INT}])
#TODO - Add inhereted stats/props

		


#func _get_property_list() -> Array[Dictionary]:
	#var props: Array[Dictionary]
#
	#props.append({
		#name="Ranks", type=TYPE_NIL,
		#hint_string="rank",
		#usage=PROPERTY_USAGE_CATEGORY
	#})
#
	#for stat: StringName in VISIBLE_STATS:
		#props.append({
			#name="rank_" + stat,
			#type=TYPE_FLOAT,
			#hint=PROPERTY_HINT_RANGE,
			#hint_string="{min}, {max}, 1, suffix: {grade} ".format({min=MIN_RANK, max=MAX_RANK, grade=get_grade(stat)}),
			#usage=PROPERTY_USAGE_DEFAULT,
		#})
#
	#props.append({
		#name="Experience", type=TYPE_NIL,
		#hint_string="level",
		#usage=PROPERTY_USAGE_CATEGORY
	#})
#
	#for stat: StringName in VISIBLE_STATS:
		## var hs: String = "0, {max}, 1, suffix:LV{lv}({p}/{mp}) ".format({max=MAX_EXPERIENCE, p=get_level_progress(stat), mp=EXPERIENCE_PER_LEVEL})
		#props.append({
			#name="experience_" + stat,
			#type=TYPE_INT,
			#hint=PROPERTY_HINT_RANGE,
			#hint_string="0, {max}, 1, suffix:LV{l} ({p}/{mp}) ".format({max=MAX_EXPERIENCE, l=get_level(stat), p=get_level_progress(stat), mp=EXPERIENCE_PER_LEVEL}),
			#usage=PROPERTY_USAGE_DEFAULT,
		#})
#
#
	#return props
#
#
#func _get(property: StringName) -> Variant:
	#
	#if "experience_" in property:
		#return get_experience(property.trim_prefix("experience_"), 0)
	#
	#if "rank_" in property:
		#return ranks.get(property.trim_prefix("rank_"), 0)
	#
	#return null
#
#
#func _set(property: StringName, value: Variant) -> bool:
	#if "experience_" in property:
		#set_experience(property.trim_prefix("experience_"), value)
		#notify_property_list_changed()
		#return true
#
	#return false


func _validate_property(property: Dictionary) -> void:
	match property.name:
		var p_name when p_name in VISIBLE_STATS:
			property.hint = PROPERTY_HINT_RANGE
			property.hint_string = "0.0, 9999, 1.0, hide_slider, suffix: " + get_grade(property.name)
			# property.usage |= PROPERTY_USAGE_READ_ONLY

#endregion Properties

func _to_string() -> String:
	return "Stats-%s" % (name if name else get_instance_id())
