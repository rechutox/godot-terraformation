shader_type spatial;

uniform sampler2D heightmap;
uniform int terrain_size;
uniform int terrain_height;
uniform int terrain_subdivisions;
uniform float normal_smooth = 5.0;

varying vec2 uv;
varying float height;


vec4 sample_point(sampler2D tex, vec2 _uv) {
    ivec2 tex_size = textureSize(tex, 0);
    vec2 uv_pix = vec2(1.0, 0.0) / float(terrain_subdivisions);
    vec2 size = vec2(uv_pix.x, 0.0) * normal_smooth;
    //ivec2 tex_uv = ivec2(int(round(_uv.x * float(tex_size.x))), int(round(_uv.y * float(tex_size.y))));
    
    vec4 sample = textureLod(heightmap, _uv, 0.0);
    //vec4 sample = texelFetch(heightmap, tex_uv, 0);
    float v = (sample.x + sample.y + sample.b) / 3.0;
    
    vec4 sample_x1 = textureLod(heightmap, _uv - uv_pix.xy, 0.0);
    //vec4 sample_x1 = texelFetch(heightmap, tex_uv - ivec2(1, 0), 0);
    float x1_v = (sample_x1.r + sample_x1.g + sample_x1.b) / 3.0;
    
    vec4 sample_x2 = textureLod(heightmap, _uv + uv_pix.xy, 0.0);
    //vec4 sample_x2 = texelFetch(heightmap, tex_uv + ivec2(1, 0), 0);
    float x2_v = (sample_x2.r + sample_x2.g + sample_x2.b) / 3.0;
    
    vec4 sample_y1 = textureLod(heightmap, _uv - uv_pix.yx, 0.0);
    //vec4 sample_y1 = texelFetch(heightmap, tex_uv - ivec2(0, 1), 0);    
    float y1_v = (sample_y1.r + sample_y1.g + sample_y1.b) / 3.0;
    
    vec4 sample_y2 = textureLod(heightmap, _uv + uv_pix.yx, 0.0);
    //vec4 sample_y2 = texelFetch(heightmap, tex_uv + ivec2(0, 1), 0);    
    float y2_v = (sample_y2.r + sample_y2.g + sample_y2.b) / 3.0;
    
    vec3 va = normalize(vec3(size.x, x2_v - x1_v, 0.0));
    vec3 vb = normalize(vec3(0.0, y2_v - y1_v, size.x));
    
    return vec4(cross(vb, va), v);
}

void vertex() {
    uv.x = VERTEX.x / float(terrain_size);    
    uv.y = VERTEX.z / float(terrain_size);
    vec4 sample = sample_point(heightmap, uv);
    VERTEX.y = sample.a * float(terrain_height);
    NORMAL = sample.rgb;
}

void fragment() {
    vec4 sample = sample_point(heightmap, uv);
    
    ALBEDO = vec3(sample.a);
    //ALBEDO = sample.rgb;
    METALLIC = 0.0;
    SPECULAR = 0.0;
    ROUGHNESS = 1.0;
}
