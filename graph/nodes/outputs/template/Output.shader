shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTexture;

void fragment() {
    COLOR = textureLod(iTexture, UV, 0.0);
}