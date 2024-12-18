shader_type canvas_item;

global uniform float TIME_SCALE;
uniform float time_offset : hint_range(-3.2, 3.2, 0.1) = 0.0;
uniform float speed : hint_range(-5.0, 5.0, 0.25)= 1.3;
uniform float sway_intensity : hint_range(0.0, 20.0, 0.1)= 1.25;

void vertex(){
	float time = (TIME+time_offset + float(VERTEX_ID))*speed/(TIME_SCALE + 0.001);
	VERTEX += vec2(sin(time),cos(time))*(sway_intensity/(2.+ 0.001));
}