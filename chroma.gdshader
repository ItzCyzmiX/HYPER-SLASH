shader_type canvas_item;

uniform sampler2D distance_curve;
uniform float intensity = 10.0;


void fragment() {
	vec2 centered_uv = UV - vec2(0.5,0.5);
	//centered_uv.x = pow(centered_uv.x, 3);
	//centered_uv.y = pow(centered_uv.y, 3);

	// Since offsetting the channels by the UVs will create no-information areas in the edges
	// all the color shifting will be done outwards rather than doing part of it inwards
	// thus, the shifted channels will be the one kept still and the one shifted the most
	float distance_from_center = abs(distance(vec2(0.0,0.0),centered_uv));
	float curve_distance_intensity = texture(distance_curve, vec2(distance_from_center)).r;

	// Channel Shifting
	float blue_channel = texture(TEXTURE, UV).b;
	float red_channel = texture(TEXTURE, UV - centered_uv * curve_distance_intensity * SCREEN_PIXEL_SIZE * intensity).r;
	float green_channel = texture(TEXTURE, UV - centered_uv * curve_distance_intensity * SCREEN_PIXEL_SIZE * intensity / 2.0).g;
	COLOR.rgb = vec3(red_channel,green_channel,blue_channel);
}