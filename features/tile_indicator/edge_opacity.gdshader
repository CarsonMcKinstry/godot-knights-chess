shader_type canvas_item;

const vec2 center = vec2(0.5,0.5);

uniform vec4 background_color : source_color;
uniform vec4 pulse_color : source_color = vec4(vec3(1.0), 1.0);

uniform float radius : hint_range(0.0, 1.0, 0.01) = 0.25;

uniform float squircle_power: hint_range(2.0, 10.0, 0.01) = 4.0;

uniform float center_opacity : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float outer_opacity :hint_range(0.0, 1.0, 0.01) = 0.5;

uniform float pulse_speed : hint_range(0.0, 5.0, 0.1) = 2.0;

float squircle_dist (vec2 uv) {

	vec2 offset = abs(uv - center);

	return pow(pow(offset.x, squircle_power) + pow(offset.y, squircle_power), 1.0 / squircle_power);
}

void fragment() {
	float dist = squircle_dist(UV);

	float alpha;

	if (dist <= radius) {
		alpha = mix(center_opacity, outer_opacity, smoothstep(0.0, radius, dist));
		//alpha = center_opacity;
	} else {
	    alpha =outer_opacity + (dist - radius) / (1.0 - radius) *outer_opacity;
	}

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	vec3 pulsing_color = mix(pulse_color.rgb, background_color.rgb, pulse);

	COLOR = vec4(pulsing_color, alpha / 2.0);
	//COLOR = vec4(background_color.rgb, alpha);

}