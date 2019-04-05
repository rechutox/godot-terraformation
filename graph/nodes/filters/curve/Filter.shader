shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTexture;
uniform sampler2D iGradient;

void fragment() {
    vec4 sample = textureLod(iTexture, UV, 0.0);
    float v = (sample.r + sample.g + sample.b) / 3.0;
    vec4 grad = textureLod(iGradient, vec2(v, 0.5), 0.0);
    float vg = (grad.r + grad.g + grad.b) / 3.0;
    
    float c = clamp(v * vg, 0.0, 1.0);
    
    COLOR = vec4(vec3(c), 1.0);
}