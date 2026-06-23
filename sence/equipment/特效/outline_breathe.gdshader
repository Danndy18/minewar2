shader_type canvas_item;

uniform float breathe : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.5) {
		discard;
	}
	vec3 amber = vec3(0.569, 0.349, 0.0);
	COLOR = vec4(mix(vec3(0.0), amber, breathe), 1.0);
}
