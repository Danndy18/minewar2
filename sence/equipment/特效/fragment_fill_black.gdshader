shader_type canvas_item;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a > 0.5) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		discard;
	}
}
