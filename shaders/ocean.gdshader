shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform vec4 albedo_color : source_color = vec4(0.0, 0.0, 1.0, 1);
uniform float metallic : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;

varying vec3 world_pos;
float wave(float base,float freq, float speed, float amp)
{
	return exp(sin((base / 255.0) * 2.0 * PI * freq + TIME * speed) * amp - 1.0);
}

const float[] xDir = {0.5,-1.0,-1.0,2.0,0.4,-1.5,2.0,-1.0,3.0,1.0,0.5,-1.0,-1.0,2.0,0.4};
const float[] yDir = {-1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0,1.0,-1.0,-1.0,1.0,-1.0};
const float[] speeds = {0.5,1.0, 0.78, 0.5, 0.5, 1.0, 2.0, 2.0, 3.0, 0.5,0.5,1.0, 0.78, 0.5, 0.5};
void vertex() {
	VERTEX.y = 0.0;
	float freq = 1.0;
	float amp = 3.0;
	for(int a = 0; a < 10; a++)
	{
		VERTEX.y += wave(xDir[a] * VERTEX.x + yDir[a] * VERTEX.z,freq, speeds[a], amp);
		freq *= 2.0;
		amp *= 0.7;
	}
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    ALBEDO = albedo_color.rgb * 0.5;
	ALBEDO += (vec3(1.0,1.0,1.0) * (world_pos.y-1.0) * 0.025).rgb;
    ALPHA = albedo_color.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}
