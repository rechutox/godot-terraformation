shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTexture;

void fragment() {
    vec4 c = texture(iTexture, UV);
    c.r = 1.0 - c.r;
    c.g = 1.0 - c.g;
    c.b = 1.0 - c.b;
    c.a = 1.0;
    COLOR = c;
}