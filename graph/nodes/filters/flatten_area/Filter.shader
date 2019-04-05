shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTextureA; // Texture base
uniform sampler2D iTextureB; // Mask
uniform float iBlend = 0.5;  // Height
uniform float iBlend2 = 0.5;  // Base blend

float get_value(vec3 color) {
    return (color.r + color.g + color.b) / 3.0;
}

vec3 clamp_color(vec3 color) {
    color.r = clamp(color.r, 0.0, 1.0);
    color.g = clamp(color.g, 0.0, 1.0);
    color.b = clamp(color.b, 0.0, 1.0);
    return color;
}

vec3 add(vec3 a, vec3 b, float blend) {
    return clamp_color(a + b * blend);    
}

void fragment() {
    vec3 base = texture(iTextureA, UV).rgb;
    float value = get_value(texture(iTextureB, UV).rgb);
    vec3 flattened = clamp_color(mix(base, add(vec3(iBlend), base, iBlend2), value));
    COLOR = vec4(flattened, 1.0);
}
