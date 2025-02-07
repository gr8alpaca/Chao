@tool
class_name WeekOverlay extends Control

const FADE_TIME: float = 0.6

signal opened
signal closed

@export var next_week_button: BaseButton

@export var button_active: bool = false: set = set_button_active 


func init(activity: Activity, stats: Stats, week_index: int) -> void:
	var con: Control = get_node(^"%StatsContainer")
	
	for child: Node in con.get_children():
		con.remove_child(child)
		child.free()
	
	for stat: String in Stats.STATS.slice(0, Stats.STAT_VISIBLE_COUNT):
		const FONT_SIZE_NORMAL: int = 40
		const FONT_SIZE_LEVEL: int = 20
		
		var info: StatInfo = preload("res://scenes/UI/stat_info.tscn").instantiate()
		info.set_font_sizes(FONT_SIZE_NORMAL, FONT_SIZE_LEVEL, 40)
		info.stat_name = stat
		info.stats = stats
		con.add_child(info)
	
	%NameLabel.text = stats.name.capitalize()
	%WeekLabel.text = "Week %d" % week_index
	%ActivityLabel.text = activity.name.capitalize()
	set_stat_displays(activity.get_stat_changes())


func _ready() -> void:
	if not Engine.is_editor_hint():
		%NextWeekButton.pressed.connect(_on_pressed.bind(%NextWeekButton))
		$NextWeekTweak.opened.connect(%NextWeekButton.grab_focus, CONNECT_DEFERRED)
	
	for child: Node in get_children():
		if child is Tweak: child.close()


func open() -> void:
	const OPEN_DELAY: float = 0.4
	await create_tween().tween_interval(0.3).finished
	
	$WeekTweak.open()
	$ActivityTweak.open(OPEN_DELAY)
	$NameTweak.open(OPEN_DELAY * 2)
	$StatsTweak.open(OPEN_DELAY * 3)
	
	create_tween().tween_callback(emit_signal.bind(&"opened")).set_delay(OPEN_DELAY * 3 + $StatsTweak.duration_sec)


func close() -> void:
	set_button_active(false)
	$WeekTweak.close()
	$ActivityTweak.close()
	$NameTweak.close()
	$StatsTweak.close()
	closed.emit()


func set_stat_displays(stat_names: PackedStringArray) -> void:
	for stat_info: StatInfo in get_node(^"%StatsContainer").get_children():
		stat_info.visible = stat_info.stat_name in stat_names


func set_button_active(val: bool) -> void:
	button_active = val
	$NextWeekTweak.active = val
	%NextWeekButton.disabled = !val


func _on_pressed(but: BaseButton) -> void:
	but.release_focus()
