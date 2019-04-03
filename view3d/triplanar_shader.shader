// https://medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a
// https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch01.html
// https://blog.selfshadow.com/publications/blending-in-detail
// http://www.gamasutra.com/blogs/AndreyMishkinis/20130716/196339/Advanced_Terrain_Texture_Splatting.php
// https://gamedevelopment.tutsplus.com/articles/use-tri-planar-texture-mapping-for-better-terrain--gamedev-13821
shader_type spatial;

uniform sampler2D heightmap;
uniform vec2 terrain_size = vec2(100.0, 20.0);
uniform int terrain_subdivisions;
uniform float terrain_normal_strength = 60.0;
uniform float terrain_flat_start = 0.0;
uniform float terrain_flat_stop = 0.9;
uniform float terrain_cliff_start = 0.2;
uniform float terrain_cliff_stop = 0.6;
uniform float terrain_sand_start = 1.0;
uniform float terrain_sand_stop = 2.0;
uniform float terrain_snow_start = 20.0;
uniform float terrain_snow_stop = 18.0;

uniform sampler2D texture_base;
uniform sampler2D texture_flat;
uniform sampler2D texture_cliff;
uniform sampler2D texture_sand;
uniform sampler2D texture_snow;

uniform float triplanar_scale = 1.0;
uniform float triplanar_blending = 0.15;
uniform float triplanar_blending_depth = 0.05;

// Convert rgb to value
float toGray(vec3 color) {
    return (color.r + color.b + color.g) / 3.0;    
}

// Returns the value of the sample 
float sampleHeight(sampler2D tex, vec2 p) {
    return toGray(textureLod(tex, p, 0.0).rgb);
}

// Returns the vertex normal in .xyz and height in .w
vec4 sampleVertex(sampler2D tex, vec3 p) {
    vec2 grid_size = vec2(terrain_size.x / float(terrain_subdivisions), 0.0);
    vec2 uv_center = p.xz / terrain_size.x;
    vec2 uv_left = (p.xz - grid_size.xy) / terrain_size.x;
    vec2 uv_right = (p.xz + grid_size.xy) / terrain_size.x;
    vec2 uv_top = (p.xz - grid_size.yx) / terrain_size.x;
    vec2 uv_bottom = (p.xz + grid_size.yx) / terrain_size.x;
    
    float h_center = sampleHeight(heightmap, uv_center);
    float h_left = sampleHeight(heightmap, uv_left);
    float h_right = sampleHeight(heightmap, uv_right);
    float h_top = sampleHeight(heightmap, uv_top);
    float h_bottom = sampleHeight(heightmap, uv_bottom);
    
    float n_x = h_left - h_right;
    float n_z = h_top - h_bottom;
    float n_y = 2.0 * grid_size.x / terrain_size.y;
    
    vec3 normal = normalize(vec3(n_x, n_y, n_z));
    
    return vec4(normal, h_center);
}

// Heightmap based blending
// color.a is height
// a1 & a2 are blend strength
// http://www.gamasutra.com/blogs/AndreyMishkinis/20130716/196339/Advanced_Terrain_Texture_Splatting.php
vec3 heightmap_blending(vec3 color1, float a1, vec3 color2, float a2) {
    float depth = triplanar_blending_depth;
    // Texture height values
    float h1 = toGray(color1);
    float h2 = toGray(color2);
    //float ma = max(color1.r + a1, color2.r + a2) - depth;
    float ma = max(h1 + a1, h2 + a2) - depth;

    float b1 = max(h1 + a1 - ma, 0);
    float b2 = max(h2 + a2 - ma, 0);

    return (color1.rgb * b1 + color2.rgb * b2) / (b1 + b2);
}

// Returns a triplanar sample
vec4 sampleTriplanar(sampler2D tex, vec3 world_pos, vec3 world_normal) {
    vec3 axis_sign = sign(world_normal);
    
    // Get planar projections
    vec4 x_axis = textureLod(tex, world_pos.yz * triplanar_scale * axis_sign.x, 0.0);
    vec4 y_axis = textureLod(tex, world_pos.xz * triplanar_scale * axis_sign.y, 0.0);
    vec4 z_axis = textureLod(tex, world_pos.xy * triplanar_scale * axis_sign.z, 0.0);
    
    // Calculate blending weights
    vec3 blend = abs(world_normal);
    //vec3 blend = pow(world_normal, vec3(4.0));
    blend /= dot(blend, vec3(1.0));
    
    // Get height from texture using heighmap blending
    // We could fetch the height from texture alpha too... but grayscale will do for now
    //vec3 heights = vec3(x_axis.a, y_axis.a, z_axis.a) * (blend * 3.0);
    //vec3 heights = vec3(toGray(x_axis.rgb), toGray(y_axis.rgb), toGray(z_axis.rgb)) * (blend * 3.0);
    vec3 heights = vec3(x_axis.r, y_axis.r, z_axis.r) * (blend * 3.0); // faster
    
    // triplanar_blending must be >= 0.01 and <= 1.0
    float height_start = max(max(heights.x, heights.y), heights.z) - triplanar_blending;
    vec3 h = max(heights - vec3(height_start, 0.0, 0.0), vec3(0.0));
    blend = h / dot(h, vec3(1.0));
    
    // Blend the results of the 3 planar projections
    return x_axis * blend.x + y_axis * blend.y + z_axis * blend.z;
}

float inverse_lerp(float v, float min_a, float max_a, float min_b, float max_b) {
 return ((v-min_a)/(max_a-min_a))*(max_b-min_b)+min_b;   
}

vec3 sampleTerrain(vec3 v_pos, vec3 v_normal) {
    vec3 color = sampleTriplanar(texture_base, v_pos, v_normal).rgb;
    
    float cliff_factor = abs(dot(v_normal, vec3(0.0, 1.0, 0.0)));
    if (cliff_factor <= abs(terrain_cliff_stop)) {
        vec3 tex = sampleTriplanar(texture_cliff, v_pos, v_normal).rgb;
        float f = 1.0 - inverse_lerp(cliff_factor, terrain_cliff_start, abs(terrain_cliff_stop), 0.0, 1.0);
        //f = clamp(pow(f * terrain_size.y, 2.0), 0.0, 1.0);
        color = heightmap_blending(color, 1.0 - f , tex, f);
        //color = vec3(f);
    }
    
    float flat_factor = 1.0 - abs(dot(v_normal, vec3(0.0, 1.0, 0.0)));
    if (flat_factor <= terrain_flat_stop) {
        vec3 tex = sampleTriplanar(texture_flat, v_pos, v_normal).rgb;
        float f = 1.0 - inverse_lerp(flat_factor, terrain_flat_start, terrain_flat_stop, 0.0, 1.0);
        color = heightmap_blending(color, 1.0 - f, tex, f);
        //color = vec3(f);
    }
    
    if (v_pos.y <= terrain_sand_stop) {
        vec3 sand = sampleTriplanar(texture_sand, v_pos, v_normal).rgb;
        float f = 1.0 - inverse_lerp(v_pos.y, terrain_sand_start, terrain_sand_stop, 0.0, 1.0);
        //f *= terrain_sand_sharpness;//pow(f, 2.0);
        color = heightmap_blending(color, 0.5, sand, f);
        //color = vec3(f);
    }
    
    if (v_pos.y >= terrain_snow_stop) {
        vec3 sand = sampleTriplanar(texture_snow, v_pos, v_normal).rgb;
        float f = 1.0 - inverse_lerp(v_pos.y, terrain_snow_start, terrain_snow_stop, 0.0, 1.0);
        //f *= terrain_snow_sharpness;
        color = heightmap_blending(color, 1.0 - f, sand, f);
        //color = vec3(f);
    }
    
//    if (v_pos.y >= terrain_sand_start && v_pos.y <= terrain_sand_start + .01) {
//        color = vec3(1.0, 0., 0.);
//    }
//    if (v_pos.y >= terrain_sand_stop && v_pos.y <= terrain_sand_stop + .01) {
//        color = vec3(1.0, 0., 0.);
//    }
    
    //color = vec3(v_pos.y);

    return color;
}

varying vec4 v_data;
varying vec3 v_pos;

void vertex() {
    v_data = sampleVertex(heightmap, VERTEX);
    VERTEX.y = v_data.w * terrain_size.y;
    v_pos = VERTEX;
    NORMAL = v_data.xyz;
}

void fragment() {
    //ALBEDO = vec3(.3); // Render a base color
    //ALBEDO = vec3(v_data.a); // Render height
    //ALBEDO = v_data.rgb; // Render normals
    //ALBEDO = v_pos / terrain_size.x; // Render position
    //ALBEDO = textureLod(texture_base, UV, 0.0).rgb; // Render uv-base texture
    //ALBEDO = sampleTriplanar(texture_base, v_pos, v_data.rgb).rgb; // Render triplanar
    ALBEDO = sampleTerrain(v_pos, v_data.rgb); // Render terrain
    METALLIC = 0.0;
    SPECULAR = 0.0;
    ROUGHNESS = 1.0;
}
