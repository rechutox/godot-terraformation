shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTextureA;
uniform sampler2D iTextureB;
uniform int iMethod;
uniform float iAmount;

vec4 clamp_color(vec4 c) {
    c.r = clamp(c.r, 0.0, 1.0);
    c.g = clamp(c.g, 0.0, 1.0);
    c.b = clamp(c.b, 0.0, 1.0);
    c.a = 1.0;
    return c;    
}

vec4 add(vec4 a, vec4 b, float amount) {
    return clamp_color(a + b * amount);
}

vec4 sub(vec4 a, vec4 b, float amount) {
    return clamp_color(a - b * amount);
}

vec4 multiply(vec4 a, vec4 b, float amount) {
    return clamp_color(a * b * amount);
}

vec4 divide(vec4 a, vec4 b, float amount) {
    vec4 c = vec4(0.0);
    b = clamp_color(b * amount);
    c.r = b.r > 0.0 ? a.r / b.r : 0.0;
    c.g = b.g > 0.0 ? a.g / b.g : 0.0;
    c.b = b.b > 0.0 ? a.b / b.b : 0.0;
    return clamp_color(c);
}

vec4 max_pass(vec4 a, vec4 b, float amount) {
    vec4 c = clamp_color(max(a, b));
    return mix(a, c, amount);
}

vec4 min_pass(vec4 a, vec4 b, float amount) {
    vec4 c = clamp_color(min(a, b));
    return mix(a, c, amount);
}

vec4 screen(vec4 a, vec4 b, float amount) {
    vec4 c = clamp_color(vec4(1.0) - (vec4(1.0) - a) * (vec4(1.0) - b));
    return mix(a, c, amount);
}

vec4 overlay(vec4 a, vec4 b, float amount) {
    vec4 c = vec4(1.0);
    c.r = c.r < 0.5 ? 2.0 * a.r * b.r : 1.0 - 2.0 * (1.0 - b.r) * (1.0 - a.r);
    c.g = c.g < 0.5 ? 2.0 * a.g * b.g : 1.0 - 2.0 * (1.0 - b.g) * (1.0 - a.g);
    c.b = c.b < 0.5 ? 2.0 * a.b * b.b : 1.0 - 2.0 * (1.0 - b.b) * (1.0 - a.b);
    return mix(a, clamp_color(c), amount);
}

void fragment() {
    if (iMethod == 0)
        COLOR = mix(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 1)
        COLOR = add(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 2)
        COLOR = sub(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 3)
        COLOR = multiply(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 4)
        COLOR = divide(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 5)
        COLOR = max_pass(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 6)
        COLOR = min_pass(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 7)
        COLOR = screen(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else if (iMethod == 8)
        COLOR = overlay(texture(iTextureA, UV), texture(iTextureB, UV), iAmount);
    else
        COLOR = texture(iTextureA, UV);
}