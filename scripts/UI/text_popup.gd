@tool
class_name TextPop extends Label

enum {FADE_NONE, FADE_NORMAL, FADE_COLOR}
var fade: int = FADE_NONE
var velocity: Vector2

var is_started: bool

var duration_sec: float = 1.5:
	set(val): duration_sec = maxf(duration_sec, 0.4)

var alternate_color: Color = Color.WHITE_SMOKE


func _init() -> void:
	set_process(false)
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING


func set_time(duration_sec: float) -> TextPop:
	self.duration_sec = duration_sec
	return self

func _process(delta: float) -> void:
	if not visible or Engine.is_editor_hint():
		return
	
	position += velocity*delta

func start(duration_sec: float = self.duration_sec, is_one_shot: bool = true) -> void:
	const TRANSITION_TIME_RATIO: float = 0.15
	const COLOR_TWEEN_SECONDS: float = 0.8
	
	var alpha_tween_time_sec: float = minf(TRANSITION_TIME_RATIO * duration_sec, 1.0)
	var color_tween_time_sec: float = minf(COLOR_TWEEN_SECONDS * duration_sec, 1.8)
	
	self.duration_sec = duration_sec
	set_process(velocity != Vector2())
	
	if fade & FADE_NORMAL:
		var tw: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, ^"modulate:a", 1.0, alpha_tween_time_sec).from(0.0)
		tw.tween_interval(duration_sec - alpha_tween_time_sec * 2.0)
		tw.tween_property(self, ^"modulate:a", 0.0, alpha_tween_time_sec).from(1.0)
	
	if fade & FADE_COLOR:
		for p: String in ["r", "g", "b"]:
			var tw: Tween = create_tween().set_loops(0).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT_IN)
			tw.tween_property(self, "modulate:" + p, alternate_color[p], color_tween_time_sec).from(modulate[p])
			tw.tween_property(self, "modulate:" + p, modulate[p], color_tween_time_sec).from(alternate_color[p])
	
	visible = true
	
	if is_one_shot:
		create_tween().tween_callback(queue_free).set_delay(duration_sec)


func set_txt(text_val: String) -> TextPop:
	text = text_val
	return self

func set_pos(pos: Vector2) -> TextPop:
	position = pos
	return self

func set_vel(vel: Vector2) -> TextPop:
	velocity = vel
	return self

func set_fs(val: int) -> TextPop:
	add_theme_font_size_override("font_size", val)
	return self

func set_col(col: Color) -> TextPop:
	add_theme_color_override("font_color", col)
	return self

func set_alt_col(col: Color) -> TextPop:
	alternate_color = col
	return self

func set_fade(fade: int = FADE_NONE) -> TextPop:
	self.fade = fade
	return self
