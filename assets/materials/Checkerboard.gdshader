shader_type spatial;

void fragment() {
    vec2 uv = UV * 40.0;
    float c = step(0.5, fract(uv.x)) + step(0.5, fract(uv.y));
    c = mod(c, 2.0);
    ALBEDO = mix(vec3(0.4), vec3(1), c);
}
