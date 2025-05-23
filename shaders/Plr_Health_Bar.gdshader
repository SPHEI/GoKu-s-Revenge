shader_type canvas_item;

uniform int lives = 3;

void fragment() {
	for(int i = 0; i < lives; i++)
	{
		if((UV.x > 1.0/float(lives) *float(i) &&
		   UV.x < 1.0/float(lives) *float(i) + 0.01) ||
			UV.y < 0.05 || UV.y > 0.95 || UV.x < 0.01 || UV.x > 0.99 
		)
		{
			COLOR = vec4(0,0,0,1);
		}
	}
}

