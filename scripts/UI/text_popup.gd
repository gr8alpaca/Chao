@tool
class_name TextPop extends Label

enum {FADE_NONE, FADE_NORMAL, FADE_COLOR}
@export var fade: int = FADE_NONE

@export var velocity: Vector2:
	set(val):
		velocity = val
		set_process(velocity != Vector2.ZERO)


var time: float = 1.5:
	get: return maxf(time, 0.5)

var alternate_color: Color = Color.WHITE_SMOKE


func _init() -> void:
	set_process(false)
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING


func set_time(time: float) -> TextPop:
	self.time = time
	return self

func _process(delta: float) -> void:
	if not velocity:
		set_process(false)
		return

	if not visible or Engine.is_editor_hint():
		return
	
	position += velocity

func start(time: float = self.time, is_one_shot: bool = true) -> void:
	const ALPHA_SECONDS: float = 0.4
	const COLOR_TWEEN_SECONDS: float = 0.8

	self.time = time
	
	if fade & FADE_NORMAL:
		var tw: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, ^"modulate:a", 1.0, ALPHA_SECONDS).from(0.0)
		tw.tween_interval(time)
		tw.tween_property(self, ^"modulate:a", 0.0, ALPHA_SECONDS).from(1.0)

	if fade & FADE_COLOR:
		for p: String in ["r", "g", "b"]:
			var tw: Tween = create_tween().set_loops(0).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT_IN)
			tw.tween_property(self, "modulate:" + p, alternate_color[p], COLOR_TWEEN_SECONDS).from(modulate[p])
			tw.tween_property(self, "modulate:" + p, modulate[p], COLOR_TWEEN_SECONDS).from(alternate_color[p])

	visible = true

	if is_one_shot:
		create_tween().tween_callback(queue_free).set_delay(time + (ALPHA_SECONDS * 2.0 if fade & FADE_NORMAL else 0.0))


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
