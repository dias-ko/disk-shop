shader_type spatial;
render_mode diffuse_lambert, specular_disabled, depth_test_disabled;
uniform vec4 tint : source_color = vec4(1.0);
void fragment() {
	ALBEDO = tint.rgb;
	ROUGHNESS = 1.0;
	ALPHA = 1.0;
}
