shader_type spatial;

uniform sampler2D heightmap;
uniform int terrain_size;
uniform int terrain_height;
uniform int terrain_subdivisions;
uniform float normal_smooth = 5.0;

uniform sampler2D base;
uniform sampler2D flat_land;
uniform sampler2D cliff;
uniform sampler2D sand;
uniform sampler2D snow;
uniform float uv_scale = 5.0;
uniform float triplanar_scale = 4.0;
uniform float triplanar_blend_sharpness = 1.0;
uniform float sand_height = 1.2;
uniform float sand_falloff = 0.7;
uniform float snow_height = 8.0;
uniform float snow_falloff = 1.8;
uniform float flat_land_dot = 0.75;
uniform float flat_land_falloff = 0.2;
uniform float cliff_dot = 0.2;
uniform float cliff_falloff = 0.1;
uniform bool use_triplanar_mapping = true;


varying vec2 uv;
varying float height;
varying vec3 vertex_position;
varying vec3 vertex_normal;
varying float slope_dot;


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

mat3 get_triplanar_uv(vec3 position, vec3 normal) {
    // remember we only need uvs[k].xy!
	mat3 uvs;
    
	uvs[0] = vec3(-position.zy, 1.0) / triplanar_scale;
	uvs[1] = vec3(-position.xz, 1.0) / triplanar_scale;
	uvs[2] = vec3(-position.xy, 1.0) / triplanar_scale;
    
    //uvs[0].y -= 0.5 * triplanar_scale;
	//uvs[2].x -= 0.5 * triplanar_scale;
    
    if (normal.x < 0.0) {
		uvs[0].x = -uvs[0].x;
	}
	if (normal.y < 0.0) {
		uvs[1].x = -uvs[1].x;
	}
	if (normal.z >= 0.0) {
		uvs[2].x = -uvs[2].x;
	}
    
	return uvs;
}

vec3 get_triplanar_weights(vec3 normal) {
    if (length(normal) == 0.0) return vec3(1.0);
	vec3 weight = pow(abs(normal), vec3(triplanar_blend_sharpness));
    return weight / (weight.x + weight.y + weight.z);
}

vec3 sample_triplanar(sampler2D tex, vec3 position, vec3 normal) {
    mat3 uvs = get_triplanar_uv(position, normal);
	vec3 weights = get_triplanar_weights(normal);
    
	vec3 albedo_x = texture(tex, uvs[0].xy).rgb * weights.x;
	vec3 albedo_y = texture(tex, uvs[1].xy).rgb * weights.y;
	vec3 albedo_z = texture(tex, uvs[2].xy).rgb * weights.z;
    
	return albedo_x + albedo_y + albedo_z;
}

vec3 sample(sampler2D tex, vec2 _uv) {
    if (use_triplanar_mapping)
        return sample_triplanar(tex, vertex_position, vertex_normal);
    return texture(tex, _uv).rgb;    
}

vec3 terrain_fragment(vec2 _uv) {
    vec3 color = sample(base, _uv);
    
    if (abs(slope_dot) >= flat_land_dot - flat_land_falloff) {
        float falloff = 1.0;
        if (slope_dot < flat_land_dot) {
            falloff = 1.0 - (flat_land_dot - slope_dot) / flat_land_falloff;
        }
        color = mix(color, sample(flat_land, _uv), falloff);
    }
    if (height <= sand_height + sand_falloff) {
        float falloff = 1.0;
        if (height > sand_height) {
            falloff = 1.0 - (height - sand_height) / sand_falloff;
        }
        color = mix(color, sample(sand, _uv), falloff);
    }
    if (height >= snow_height - snow_falloff) {
        float falloff = 1.0;
        if (height < snow_height) {
            falloff = 1.0 - (snow_height - height) / snow_falloff;
        }
        color = mix(color, sample(snow, _uv), falloff);
    }
    
    if (abs(slope_dot) <= cliff_dot + cliff_falloff) {
        float falloff = 1.0;
        if (slope_dot > cliff_dot) {
            falloff = 1.0 - (slope_dot - cliff_dot) / cliff_falloff;
        }
        color = mix(color, sample_triplanar(cliff, vertex_position, vertex_normal), falloff);
    }
    
    return color;
}

void vertex() {
    // For height
    uv.x = VERTEX.x / float(terrain_size);    
    uv.y = VERTEX.z / float(terrain_size);
    vec4 sample = sample_point(heightmap, uv);
    VERTEX.y = sample.a * float(terrain_height);
    NORMAL = sample.rgb;
    // For terrain
    vertex_position = VERTEX;
    vertex_normal = NORMAL;
    height = VERTEX.y;
    slope_dot = dot(NORMAL, vec3(0.0, 1.0, 0.0));    
}

void fragment() {
    //ALBEDO = vec3(sample_point(heightmap, uv)); // render the heightmap
    //ALBEDO = sample.rgb; // Render the normals
    ALBEDO = terrain_fragment(UV * uv_scale); // Render the terrain textures
    METALLIC = 0.0;
    SPECULAR = 0.0;
    ROUGHNESS = 1.0;
}
