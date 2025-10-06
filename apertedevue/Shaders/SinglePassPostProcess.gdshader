shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform bool _usePixelise=true;

uniform vec2 pixelSize = vec2(32.0, 28.0);

vec3 Pixelise(vec2 screenPixelSize, vec2 screenUV)
{
	vec2 norm_size = pixelSize * screenPixelSize;
	bool less_than_half = mod(screenUV.y / 2.0, norm_size.y) / norm_size.y < 0.5;
	vec2 uv = screenUV + vec2(norm_size.x * 0.5 * float(less_than_half), 0.0);
	vec2 center_uv = floor(uv / norm_size) * norm_size;
	vec2 norm_uv = mod(uv, norm_size) / norm_size;
	center_uv += mix(vec2(0.0,0.0),
				mix(mix(vec2(norm_size.x, -norm_size.y),
						vec2(0.0,-norm_size.y),
						float(norm_uv.x < 0.5)),
					mix(vec2(0.0, -norm_size.y),
						vec2(-norm_size.x,-norm_size.y),
						float(norm_uv.x < 0.5)),
					float(less_than_half)),
				float(norm_uv.y < 0.3333333) * float(norm_uv.y / 0.3333333 < abs(norm_uv.x - 0.5) * 2.0));

	return textureLod(screen_texture, center_uv, 0.0).xyz;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 textColor = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

	vec3 color=textColor;
	
	if(_usePixelise)
		textColor = Pixelise(SCREEN_PIXEL_SIZE, SCREEN_UV);
	
	COLOR.rgb = textColor;//color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
