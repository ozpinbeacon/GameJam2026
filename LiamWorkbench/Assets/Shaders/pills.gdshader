shader_type canvas_item;

uniform bool enabled = true;
uniform float ca_amount = 0.4;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D offset_texture : hint_default_white;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//// Called for every pixel the material is visible on.
	vec4 texture_color = texture(screen_texture, UV);
	vec4 color = texture_color;
	
	if (enabled == true) {
		float adjustment_amount = ca_amount * texture(offset_texture, UV).r / 100.0;
		color.r = texture(screen_texture, vec2(UV.x + adjustment_amount, UV.y)).r;
		color.g = texture(screen_texture, UV).g;
		color.b = texture(screen_texture, vec2(UV.x - adjustment_amount, UV.y)).b;
	}
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
