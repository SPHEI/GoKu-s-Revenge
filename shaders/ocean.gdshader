shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform vec4 albedo_color : source_color = vec4(0.0, 0.0, 1.0, 1);
uniform float metallic : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    ALBEDO = albedo_color.rgb;
    ALPHA = albedo_color.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}


void vertex() {
    VERTEX.y += sin((VERTEX.x + VERTEX.z) * .5 + TIME) * 1.0;
	VERTEX.y += sin((VERTEX.x) * 0.02 + TIME) * .25;
	VERTEX.y += cos((VERTEX.x - VERTEX.z) * 0.1 + TIME) * .5;
}