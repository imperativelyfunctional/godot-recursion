shader_type canvas_item;

uniform float time_to_fade : hint_range(0.0, 10.0) = 5.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float elapsed_time = TIME;
    float alpha = 1.0 - (elapsed_time / time_to_fade);
    tex_color.a *= clamp(alpha, 0.8, 1.0);
    COLOR = tex_color;
}