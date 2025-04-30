shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform vec4 albedo_color : source_color = vec4(0.0, 0.5, 1.0, 1);
uniform float metallic : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform bool foam;
uniform float maxAmp: hint_range(0.0, 20.0) = 2.0;
uniform float speedMult: hint_range(0.0, 20.0) = 1.0;

varying vec3 local_pos;

const float[] xDir = {0.5,-1.0,-1.0,2.0,0.4,-1.5,2.0,-1.0,3.0,1.0};
const float[] yDir = {-1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0};
const float[] speeds = {0.5,1.0,0.78,0.5,0.5,1.0,2.0,2.0,3.0,0.5};

#define TWOPI 6.28318530718

float wave(float base,float freq, float speed, float amp)
{
	return exp(sin((base / 255.0) * TWOPI * freq + TIME * speed) * amp - 1.0);
}

float derivative(float base, float freq, float speed, float amp, float t) {
	float phase = (base / 255.0) * TWOPI * freq + t * speed;
	return amp * speed * exp(sin(phase) * amp - 1.0) * cos(phase);
}

vec3 totalDerivative(float t) {
	vec3 result = vec3(0.0,0.0,0.0);
	float freq = 1.0;
	float amp = maxAmp;
	for(int a = 0; a < 10; a++)
	{
		float base = xDir[a] * local_pos.x + yDir[a] * local_pos.z;
		float s = speeds[a] * speedMult;
		result.x += derivative(base, freq, s, amp, t);
		result.y += derivative(base, freq, s, amp, t + 0.5);
		result.z += derivative(base, freq, s, amp, t - 0.5);
		freq *= 2.0;
		amp *= 0.8;
	}
	return result;
}

void vertex() {
	VERTEX.y = 0.0;
	float freq = 1.0;
	float amp = maxAmp;
	for(int a = 0; a < 10; a++)
	{
		VERTEX.y += wave(xDir[a] * VERTEX.x + yDir[a] * VERTEX.z,freq, speeds[a] * speedMult, amp);
		freq *= 2.0;
		amp *= 0.8;
	}
	local_pos = VERTEX.xyz;
}
void fragment() {
	ALBEDO = albedo_color.rgb * 0.5;
	ALBEDO += (vec3(1.0,1.0,1.0) * (local_pos.y-1.0) * 0.025).rgb;
	if(foam)
	{
		vec3 d = totalDerivative(TIME);
		if(abs(d.x) < 0.5 && d.z > 0.0 && d.y < 0.0)
		{
			ALBEDO = vec3(1.0,1.0,1.0).rgb;
		}
		else if(d.x > -1.0 && d.x < 0.0 && d.y >= 0.0)
		{
			ALBEDO += vec3(1.0,1.0,1.0).rgb * (d.x + 1.0) * 0.1;
		}
	}
	ALPHA = albedo_color.a;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}
