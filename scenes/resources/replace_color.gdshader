shader_type canvas_item;

group_uniforms palettes;
uniform sampler2D team_palette : filter_nearest;
uniform sampler2D skin_palette : filter_nearest;
group_uniforms;

uniform int team_color = 0;
uniform int skin_color : hint_enum("Light", "Medium", "Dark") = 0;

vec2 pixel_to_uv(ivec2 pixel_coords, ivec2 texture_size) {
	return vec2(
		(float(pixel_coords.x) + 0.5) / float(texture_size.x),
		(float(pixel_coords.y) + 0.5) / float(texture_size.y)
	);
}

vec4 get_palette_color(vec4 original_color, sampler2D palette, int selection) {
	ivec2 size = textureSize(palette, 0);
	int row = clamp(selection, 0, size.y - 1);
	for (int x = 0; x < size.x; x++) {
		vec4 reference_color = texture(palette, pixel_to_uv(ivec2(x, 0), size));
		if (distance(original_color, reference_color) < 0.01) {
			return texture(palette, pixel_to_uv(ivec2(x, row), size));
		}
	}
	return original_color;
}

void fragment() {
	COLOR = get_palette_color(COLOR, team_palette, team_color);
	if (skin_color > 0) {
		COLOR = get_palette_color(COLOR, skin_palette, skin_color);
	}
}