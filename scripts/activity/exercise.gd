@tool
class_name Exercise extends Activity

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var run: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var swim: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var fly: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var power: int = 0

func get_stat_changes() -> PackedStringArray:
	var stat_changes: PackedStringArray
	for stat: StringName in [&"run", &"swim", &"fly", &"power"]:
		if get(stat) != 0: stat_changes.push_back(stat)
	return stat_changes

func roll_deltas(rand: PackedInt64Array = rand_from_seed(randi())) -> Dictionary:
	var dict: Dictionary = super(rand)
	for stat: StringName in get_stat_changes():
		var t: float = float(rand[0] % 1001) / 1000.0
		rand = rand_from_seed(rand[0])
		
		
		
		
	return dict
