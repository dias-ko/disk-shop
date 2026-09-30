shader_type spatial;
render_mode diffuse_lambert, specular_disabled;
varying vec3 world_pos;
varying vec3 world_normal;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = mat3(MODEL_MATRIX) * NORMAL;
}
void fragment() {
	vec2 face = abs(world_normal.z) > 0.5 ? world_pos.xy : world_pos.zy;
	face *= vec2(2.5, 5.0);
	face.x += mod(floor(face.y), 2.0) * 0.5;
	vec2 cell = fract(face);
	float mortar = step(cell.x, 0.045) + step(cell.y, 0.085);
	float brick = fract(sin(dot(floor(face), vec2(17.13, 91.7))) * 43758.54);
	float grit = fract(sin(dot(floor(face * 14.0), vec2(12.98, 78.23))) * 43758.54);
	vec3 clay = vec3(0.55, 0.205, 0.075) * (0.82 + brick * 0.3 + grit * 0.08);
	ALBEDO = mix(clay, vec3(0.23, 0.17, 0.13), clamp(mortar, 0.0, 1.0));
	if (world_normal.y > 0.5) ALBEDO = vec3(0.38, 0.18, 0.095) * (0.92 + grit * 0.08);
	ROUGHNESS = 1.0;
}
