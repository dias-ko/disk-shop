shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float pixel_size = 2.0;
uniform float color_steps = 24.0;
uniform vec2 player_uv = vec2(0.5);
uniform float darkness_enabled = 0.0;
uniform float darkness_strength = 0.55;
uniform float clear_radius = 0.20;
uniform float falloff_radius = 0.62;
void fragment() {
	vec2 pixel = floor(FRAGCOORD.xy / pixel_size);
	vec2 uv = (pixel + 0.5) * SCREEN_PIXEL_SIZE * pixel_size;
	vec3 source = texture(screen_texture, uv).rgb;
	float pattern = mod(pixel.x + pixel.y, 2.0) * 0.5 + mod(pixel.y, 2.0) * 0.25;
	vec3 printed = floor(source * color_steps + pattern) / color_steps;
	// Resolution-independent, soft falloff; distant scenery retains 45% light.
	vec2 distance_uv = SCREEN_UV - player_uv;
	distance_uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float shade = smoothstep(clear_radius, falloff_radius, length(distance_uv));
	printed *= 1.0 - shade * darkness_strength * darkness_enabled;
	// Preserve the pure black void exactly. UI is drawn above this pass.
	COLOR = vec4(max(printed, vec3(0.0)), 1.0);
}
