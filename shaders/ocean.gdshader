shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform vec4 albedo_color : source_color = vec4(0.0, 0.5, 1.0, 1);
uniform float metallic : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform sampler2D foam_texture : filter_nearest;
uniform bool use_foam_texture;
uniform bool foam;
uniform int foamDetail: hint_range(0, 10) = 10;
uniform float maxAmp: hint_range(0.0, 20.0) = 2.0;
uniform float speedMult: hint_range(0.0, 20.0) = 1.0;

varying vec3 local_pos;

const float[] xDir = {0.5,-1.0,-1.0,2.0,0.4,-1.5,2.0,-1.0,3.0,1.0,0.5,-1.0,-1.0,2.0,0.4};
const float[] yDir = {-1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0,1.0,-1.0,-1.0,1.0,-1.0};
const float[] speeds = {0.5,1.0, 0.78, 0.5, 0.5, 1.0, 2.0, 2.0, 3.0, 0.5,0.5,1.0, 0.78, 0.5, 0.5};

float wave(float base,float freq, float speed, float amp)
{
	return exp(sin((base / 255.0) * 2.0 * PI * freq + TIME * speed) * amp - 1.0);
}

float derivative(float base, float freq, float speed, float amp, float t) {
	return amp * speed * exp(sin((base / 255.0) * 2.0 * 3.141592653589* freq + t * speed) * amp - 1.0) * cos(speed * t + (base / 255.0) * 2.0 * 3.141592653589793238 * freq);
}

float totalDerivative(float t) {
	float result = 0.0;
	float freq = 1.0;
	float amp = maxAmp;
	for(int a = 0; a < foamDetail; a++)
	{
		result += derivative(xDir[a] * local_pos.x + yDir[a] * local_pos.z, freq, speeds[a] * speedMult, amp, t);
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
		if(use_foam_texture)
		{
			vec4 foamt = texture(foam_texture, vec2(local_pos.x/512.0,local_pos.z/256.0), 0.0);
			ALBEDO = mix(ALBEDO, foamt.rgb, foamt.a * 0.5);
		}
		else if(abs(totalDerivative(TIME)) < 0.5 && totalDerivative(TIME - 0.5) > 0.0 && totalDerivative(TIME + 0.5) < 0.0)
		{
			ALBEDO = vec3(1.0,1.0,1.0).rgb;
		}
		else if(totalDerivative(TIME) > -1.0 && totalDerivative(TIME) < 0.0 && totalDerivative(TIME + 1.0) >= 0.0)
		{
			ALBEDO += vec3(1.0,1.0,1.0).rgb * (totalDerivative(TIME) + 1.0) * 0.1;
		}
	}
	ALPHA = albedo_color.a;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}
