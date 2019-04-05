shader_type canvas_item;
render_mode unshaded;

uniform sampler2D iTexture;
uniform float iMinHeight = 0.0;
uniform float iMaxHeight = 1.0;
uniform float iFalloffMin = 0.1;
uniform float iFalloffMax = 0.1;
uniform float iFalloffMinExp = 1.0;
uniform float iFalloffMaxExp = 1.0;

float get_value(vec4 color) {
    return (color.r + color.g + color.b) / 3.0;
}

void fragment() {
    float value =  get_value(texture(iTexture, UV));
    float result = 1.0;

    if (value <= iMinHeight) {
        if (value > iMinHeight - iFalloffMin) {
            result = 1.0 - pow((iMinHeight - value) / iFalloffMin, iFalloffMinExp)
        }
        else result = 0.0;
    }
    else if (value >= iMaxHeight) {
        if (value < iMaxHeight + iFalloffMax) {
            result = 1.0 - pow((value - iMaxHeight) / iFalloffMax, iFalloffMaxExp)
        }
        else result = 0.0;
    }

    vec3 c = vec3(clamp(result, 0.0, 1.0));
    COLOR = vec4(c, 1.0);   
}