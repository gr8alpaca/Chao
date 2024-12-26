shader_type canvas_item;

global uniform float TIME_SCALE;

uniform float cycle_time_sec: hint_range(0.1, 15.0, 0.1) = 7.0;

uniform vec2 max_distance = vec2(4., 4.);

// Speed y-component moves at relative to x
uniform float volatility: hint_range(0.1, 2.0, 0.1) = 1.3; 

uniform float time_offset = 0.0;
uniform bool disabled = false;

void vertex(){
	float id = float(INSTANCE_ID*16);
	
	float t = float(!disabled)*(TIME) * TIME_SCALE * TAU / cycle_time_sec + time_offset;
	VERTEX += vec2(sin(t) * max_distance.x, cos(t*volatility) * max_distance.y);
}