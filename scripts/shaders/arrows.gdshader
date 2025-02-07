shader_type canvas_item;
render_mode unshaded;

uniform bool increase = true;
uniform sampler2D tex: hint_default_white, repeat_enable;
uniform float speed : hint_range(0.0, 5.0, 0.05) = 1.0;


void fragment() {
	vec2 size = 1.0/SCREEN_PIXEL_SIZE;
	vec3 col = vec3(increase? 0.0: 1.0, increase? 1.0: 0.0, 0.0);
	
	
	//if (increase)
}

