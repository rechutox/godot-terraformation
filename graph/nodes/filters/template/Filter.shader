shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTexture;

void fragment() {
    COLOR = texture(iTexture, UV);
}