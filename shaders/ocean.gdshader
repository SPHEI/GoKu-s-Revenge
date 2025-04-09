shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, world_vertex_coords;

uniform vec4 albedo_color : source_color = vec4(0.0, 0.0, 1.0, 1);
uniform float metallic : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;

varying vec3 world_pos;

void fragment() {
    ALBEDO = albedo_color.rgb * 0.5;
	ALBEDO += (vec3(1.0,1.0,1.0) * ((sin((world_pos.x + world_pos.z) * .5 + TIME) * 1.0 + 
	sin((world_pos.x) * 0.02 + TIME) * 1.0 + 
	cos((world_pos.x - world_pos.z) * 0.1 + TIME)))/17.5).rgb;
    ALPHA = albedo_color.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    VERTEX.y += sin((VERTEX.x + VERTEX.z) * .5 + TIME) * 1.0 + 
	sin((VERTEX.x) * 0.02 + TIME) * 1.0 + 
	cos((VERTEX.x - VERTEX.z) * 0.1 + TIME) * .5;
}