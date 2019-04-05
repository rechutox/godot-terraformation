shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTextureA;
uniform sampler2D iTextureB;
uniform float iBlend = 0.5;


void fragment() {
    vec4 colA = texture(iTextureA, UV);
    vec4 colB = texture(iTextureB, UV);
    COLOR = mix(colA, colB, iBlend);
}
