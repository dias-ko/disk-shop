shader_type spatial;
render_mode diffuse_lambert, specular_disabled;
uniform vec4 tint : source_color = vec4(0.55, 0.35, 0.20, 1.0);
uniform float wobble = 0.022;
void vertex() {
	VERTEX.x += sin(TIME * 3.0 + VERTEX.y * 8.0 + MODEL_MATRIX[3].x) * wobble * VERTEX.y;
	VERTEX.z += cos(TIME * 2.5 + VERTEX.x * 7.0 + MODEL_MATRIX[3].z) * wobble * VERTEX.y;
}
void fragment() {
	vec2 texel = floor(UV * 16.0);
	float grain = fract(sin(dot(texel, vec2(12.9898, 78.233))) * 43758.5453);
	ALBEDO = tint.rgb * COLOR.rgb * (0.76 + grain * 0.16);
	ROUGHNESS = 1.0;
}
