shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTexture;
uniform float iParam1 = 0.0; // Brogthness
uniform float iParam2 = 0.0; // Contrast

void fragment() {
    vec3 sample = textureLod(iTexture, UV, 0.0).rgb;
    float v = (sample.r + sample.g + sample.b) / 3.0;
    
    // Adjust Brightness
    v = clamp(v + iParam1, 0.0, 1.0);
    
    // Adjust contrast (linearly interpolate with a gray tone)
    float c = 1.0 + iParam2;
    v = ((1.0 - c) * 0.5) + (c * v);
    
    COLOR = vec4(vec3(v), 1.0);
}