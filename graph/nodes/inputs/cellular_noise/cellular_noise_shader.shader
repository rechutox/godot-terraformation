shader_type canvas_item;
render_mode unshaded;

uniform int iType = 0;
uniform int iSeed = 0;
uniform int iVariant = 0;
uniform float iScale = 5.;
uniform vec2 iOffset = vec2(0.,0.);
uniform vec2 iParams = vec2(1.,1.);

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453*(0.5+float(iSeed)));
}

// Permutation polynomial: (34x^2 + x) mod 289
vec3 permute(vec3 x) {
  return mod((34.0 * x + 1.0) * x, 289.0);
}

vec3 hash3( vec2 p ) {
    vec3 q = vec3( dot(p,vec2(127.1,311.7)),
                   dot(p,vec2(269.5,183.3)),
                   dot(p,vec2(419.2,371.9)) );
    return fract(sin(q)*43758.5453*(0.5+float(iSeed)));
}

// Author: @patriciogv
float cellular1(vec2 p) {
    vec3 color = vec3(.0);

    // Tile the space
    vec2 i_st = floor(p);
    vec2 f_st = fract(p);

    float m_dist = 1.;  // minimun distance

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            // Neighbor place in the grid
            vec2 neighbor = vec2(float(x),float(y));

            // Random position from current + neighbor place in the grid
            vec2 point = random2(i_st + neighbor);

            // Vector between the pixel and the point
            vec2 diff = neighbor + point - f_st;

            // Distance to the point
            //float dist = diff.x*diff.x + diff.y*diff.y; // Faster
            float dist = length(diff); // Slower

            // Keep the closer distance
            m_dist = min(m_dist, dist);
        }
    }

    // Draw the min distance (distance field)
    return m_dist;    
}

// Cellular noise, returning F1 and F2 in a vec2.
// Standard 3x3 search window for good F1 and F2 values
float cellular2(vec2 P, int type_variant) {
	float K = 0.142857142857; // 1/7
	float Ko = 0.428571428571; // 3/7
	float jitter = 1.0; // Less gives more regular pattern
	vec2 Pi = mod(floor(P), 289.0);
    vec2 Pf = fract(P);
	vec3 oi = vec3(-1.0, 0.0, 1.0);
	vec3 of = vec3(-0.5, 0.5, 1.5);
	vec3 px = permute(Pi.x + oi);
	vec3 p = permute(px.x + Pi.y + oi); // p11, p12, p13
	vec3 ox = fract(p*K) - Ko;
	vec3 oy = mod(floor(p*K),7.0)*K - Ko;
	vec3 dx = Pf.x + 0.5 + jitter*ox;
	vec3 dy = Pf.y - of + jitter*oy;
	vec3 d1 = dx * dx + dy * dy; // d11, d12 and d13, squared
	p = permute(px.y + Pi.y + oi); // p21, p22, p23
	ox = fract(p*K) - Ko;
	oy = mod(floor(p*K),7.0)*K - Ko;
	dx = Pf.x - 0.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	vec3 d2 = dx * dx + dy * dy; // d21, d22 and d23, squared
	p = permute(px.z + Pi.y + oi); // p31, p32, p33
	ox = fract(p*K) - Ko;
	oy = mod(floor(p*K),7.0)*K - Ko;
	dx = Pf.x - 1.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	vec3 d3 = dx * dx + dy * dy; // d31, d32 and d33, squared
	// Sort out the two smallest distances (F1, F2)
	vec3 d1a = min(d1, d2);
	d2 = max(d1, d2); // Swap to keep candidates for F2
	d2 = min(d2, d3); // neither F1 nor F2 are now in d3
	d1 = min(d1a, d2); // F1 is now in d1
	d2 = max(d1a, d2); // Swap to keep candidates for F2
	d1.xy = (d1.x < d1.y) ? d1.xy : d1.yx; // Swap if smaller
	d1.xz = (d1.x < d1.z) ? d1.xz : d1.zx; // F1 is in d1.x
	d1.yz = min(d1.yz, d2.yz); // F2 is now not in d2.yz
	d1.y = min(d1.y, d1.z); // nor in  d1.z
	d1.y = min(d1.y, d2.x); // F2 is in d1.y, we're done.
    
    if (type_variant == 0)
	    return sqrt(d1.x*d1.x + d1.y*d1.y) * 0.6;
    if (type_variant == 1)
	    return (d1.x*d1.x + d1.y*d1.y) * 0.3;
    else {
	    vec2 F =  sqrt(d1.xy);
        return 0.1 + (F.y-F.x);
    }
}

float cellular3(vec2 p) {
    // Tile the space
    vec2 i_st = floor(p);
    vec2 f_st = fract(p);

    float m_dist = 100.;  // minimun distance
    vec2 m_point;        // minimum point

    for (int j=-1; j<=1; j++ ) {
        for (int i=-1; i<=1; i++ ) {
            vec2 neighbor = vec2(float(i),float(j));
            vec2 point = random2(i_st + neighbor);
            vec2 diff = neighbor + point - f_st;
            float dist = length(diff);

            if( dist < m_dist ) {
                m_dist = dist;
                m_point = point;
            }
        }
    }

    // Assign a color using the closest point position
    return dot(m_point,vec2(.3,.6));
}

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// http://iquilezles.org/www/articles/voronoise/voronoise.htm
float voronoise(vec2 x, vec2 uv ) {
    vec2 p = floor(x);
    vec2 f = fract(x);

    float k = 1.0+63.0*pow(1.0-uv.y,4.0);

    float va = 0.0;
    float wt = 0.0;
    for (int j=-2; j<=2; j++) {
        for (int i=-2; i<=2; i++) {
            vec2 g = vec2(float(i),float(j));
            vec3 o = hash3(p + g)*vec3(uv.x,uv.x,1.0);
            vec2 r = g - f + o.xy;
            float d = dot(r,r);
            float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
            va += o.z*ww;
            wt += ww;
        }
    }

    return va/wt;
}

void fragment() {
    if (iType == 1)
        COLOR = vec4(vec3(cellular1(UV * iScale + iOffset)), 1.0);
    else if (iType == 2)
        COLOR = vec4(vec3(cellular2(UV * iScale + iOffset, iVariant)), 1.0);
    else if (iType == 3)
        COLOR = vec4(vec3(cellular3(UV * iScale + iOffset)), 1.0);
    else
        COLOR = vec4(vec3(voronoise(UV * iScale + iOffset, iParams)), 1.0);
}