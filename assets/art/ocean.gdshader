shader_type canvas_item;
render_mode unshaded;
uniform float motion_time = 0.0;
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}
void fragment() {
    vec2 p = UV * vec2(12.0, 9.0);
    vec2 drift = vec2(motion_time * 0.055, -motion_time * 0.035);
    float swell = noise(p * 0.55 + drift);
    float detail = noise(p * 3.7 + drift * 1.9);
    float crest = smoothstep(0.87, 0.98, sin(p.y * 9.0 + noise(p * 1.8 + drift) * 12.0 + motion_time * 0.35));
    crest *= smoothstep(0.55, 0.85, detail);
    vec3 sea = mix(vec3(0.075, 0.43, 0.47), vec3(0.16, 0.59, 0.58), swell * 0.8 + UV.y * 0.12);
    sea += vec3(0.22, 0.37, 0.31) * crest * 0.13;
    COLOR = vec4(sea, 1.0);
}
