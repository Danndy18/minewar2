shader_type canvas_item;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.r < 0.01 && c.g < 0.01 && c.b < 0.01 && c.a > 0.0) {
		discard;
	}
	COLOR = c;
}
