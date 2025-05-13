shader_type canvas_item;

uniform float level = 0.0;

void vertex() {}

void fragment() {
	COLOR += vec4(1.0*level,1.0*level,1.0*level,COLOR.a);
}
