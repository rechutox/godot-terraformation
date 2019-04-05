shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTextureA; // Texture base
uniform sampler2D iTextureB; // Mask
uniform float iBlend = 0.5;

float get_value(vec3 color) {
    return (color.r + color.g + color.b) / 3.0;
}

vec3 clamp_color(vec3 color) {
    color.r = clamp(color.r, 0.0, 1.0);
    color.g = clamp(color.g, 0.0, 1.0);
    color.b = clamp(color.b, 0.0, 1.0);
    return color;
}

void fragment() {
    vec3 base = texture(iTextureA, UV).rgb;
    float value = get_value(texture(iTextureB, UV).rgb);
    vec3 masked = clamp_color(mix(vec3(0.0), base, value));
    vec3 final = clamp_color(mix(base, masked, iBlend));
    COLOR = vec4(final, 1.0);
}
