shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTextureA;
uniform sampler2D iTextureB;
uniform float iBlend = 0.5;


void fragment() {
    vec3 colA = texture(iTextureA, UV).rgb;
    vec3 colB = texture(iTextureB, UV).rgb;
    vec3 colC = colA + colB * iBlend;
    colC.r = clamp(colC.r, 0.0, 1.0);
    colC.g = clamp(colC.g, 0.0, 1.0);
    colC.b = clamp(colC.b, 0.0, 1.0);
    COLOR = vec4(colC, 1.0);
}
