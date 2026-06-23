shader_type canvas_item;

uniform vec4 replace_1 : source_color;
uniform vec4 replace_2 : source_color;
uniform vec4 replace_3 : source_color;
uniform vec4 replace_4 : source_color;

const vec4 KEY_1 = vec4(0.584, 0.584, 0.584, 1.0);
const vec4 KEY_2 = vec4(0.749, 0.749, 0.749, 1.0);
const vec4 KEY_4 = vec4(0.882, 0.882, 0.882, 1.0);
const vec4 KEY_3 = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (all(lessThan(abs(c.rgb - KEY_1.rgb), vec3(0.02)))) {
		COLOR = vec4(replace_1.rgb, c.a);
	} else if (all(lessThan(abs(c.rgb - KEY_2.rgb), vec3(0.02)))) {
		COLOR = vec4(replace_2.rgb, c.a);
	} else if (all(lessThan(abs(c.rgb - KEY_4.rgb), vec3(0.02)))) {
		COLOR = vec4(replace_4.rgb, c.a);
	} else if (all(lessThan(abs(c.rgb - KEY_3.rgb), vec3(0.02)))) {
		COLOR = vec4(replace_3.rgb, c.a);
	} else {
		COLOR = c;
	}
}
