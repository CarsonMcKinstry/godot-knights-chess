shader_type canvas_item;


uniform vec4 dark : source_color;
uniform vec4 light : source_color;

const vec4 dark_color = vec4(0.0, 1.0, 0.0, 1.0);
const vec4 light_color = vec4(1.0, 0.0, 1.0, 1.0);

void fragment() {
	if (COLOR == dark_color) {
		COLOR = dark;
	} else if (COLOR == light_color) {
		COLOR = light;
	}
}