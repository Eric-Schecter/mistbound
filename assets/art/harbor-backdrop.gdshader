shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float luminance = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 muted = mix(vec3(luminance), source.rgb, 0.70);
	// Quiet cool atmosphere; preserve the illustration without competing with play.
	vec3 atmosphere = mix(muted, vec3(0.21, 0.38, 0.37), 0.12);
	float edge = smoothstep(0.25, 0.72, length(UV - vec2(0.5)));
	COLOR = vec4(atmosphere * mix(0.93, 0.75, edge), source.a);
}
