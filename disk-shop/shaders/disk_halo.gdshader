shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
uniform vec4 glow_color : source_color = vec4(1.0);
void fragment() {
	float radius = length(UV - vec2(0.5)) * 2.0;
	float soft = pow(max(0.0, 1.0 - radius), 2.0);
	float ring = (1.0 - smoothstep(0.025, 0.08, abs(radius - 0.48))) * 0.22;
	ALBEDO = glow_color.rgb;
	ALPHA = (soft * 0.65 + ring) * (0.8 + sin(TIME * 2.5) * 0.15);
}
