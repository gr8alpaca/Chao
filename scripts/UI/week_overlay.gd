@tool
class_name WeekOverlay extends Control

signal opened
signal closed

@export var stat_info_display_scene: PackedScene = preload("res://scenes/stat_info.tscn")

@export var color_rect: ColorRect

@export var next_week_button: BaseButton


@export var button_active: bool = false: set = set_button_active 


const FADE_TIME: float = 0.6


func open(activity: Activity, stats: Stats, week_index: int) -> void:
	const OPEN_DELAY: float = 0.4
	await create_tween().tween_property(color_rect, ^"color:a", 0.0, FADE_TIME).set_delay(0.3).finished
	
	%WeekLabel.text = "Week %d" % [week_index]
	$WeekTweak.open()
	
	%ActivityLabel.text = activity.name.capitalize()
	$ActivityTweak.open(OPEN_DELAY)
	
	$NameTweak.open(OPEN_DELAY * 2)
	
	set_stat_displays(activity.get_stat_changes())
	$StatsTweak.open(OPEN_DELAY * 3)
	
	create_tween().tween_callback(emit_signal.bind(&"opened")).set_delay(OPEN_DELAY * 3 + $StatsTweak.duration_sec)


func close() -> void:
	set_button_active(false)
	$WeekTweak.close()
	$ActivityTweak.close()
	$NameTweak.close()
	$StatsTweak.close()
	var tw: Tween = create_tween()
	tw.tween_property(color_rect, ^"color:a", 1.0, FADE_TIME).set_delay(0.2)
	tw.tween_callback(emit_signal.bind(&"closed"))


func set_stat_displays(stat_names: PackedStringArray) -> void:
	for stat_info: StatInfo in get_node(^"%StatsContainer").get_children():
		stat_info.visible = stat_info.stat_name in stat_names


func init(stats: Stats) -> void:
	%NameLabel.text = stats.name.capitalize()
	var con: Control = get_node(^"%StatsContainer")
	
	for child: Node in con.get_children():
		con.remove_child(child)
		child.free()
	
	for stat_name: String in Stats.VISIBLE_STATS:
		var info: StatInfo = stat_info_display_scene.instantiate()
		info.stat_name = stat_name
		info.stats = stats
		con.add_child(info)
	

func set_button_active(val: bool) -> void:
	button_active = val
	$NextWeekTweak.active = val
	%NextWeekButton.disabled = !val	
