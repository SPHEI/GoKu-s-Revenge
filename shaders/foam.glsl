#[compute]
#version 450

//Obsolete code


layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba32f, set = 0, binding = 0) uniform image2D dest_image;

// Buffer of vec3 vertex positions
layout(set = 0, binding = 1) readonly buffer Positions {
    vec3 data[];
} positions;

layout(set = 0, binding = 2) uniform TimeData {
    vec4 time;
} time;

layout(set = 0, binding = 3) uniform SizeData {
    vec4 size;
} size;


const float[] xDir = {0.5,-1.0,-1.0,2.0,0.4,-1.5,2.0,-1.0,3.0,1.0,0.5,-1.0,-1.0,2.0,0.4};
const float[] yDir = {-1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,-1.0,1.0,1.0,-1.0,-1.0,1.0,-1.0};
const float[] speeds = {0.5,1.0, 0.78, 0.5, 0.5, 1.0, 2.0, 2.0, 3.0, 0.5,0.5,1.0, 0.78, 0.5, 0.5};


float derivative(float base, float freq, float speed, float amp, float t) {
	return amp * speed * exp(sin((base / 255.0) * 2.0 * 3.141592653589* freq + t * speed) * amp - 1.0) * cos(speed * t + (base / 255.0) * 2.0 * 3.141592653589793238 * freq);
}

float totalDerivative(float x, float z,float t) {
	float result = 0.0;
	float freq = 1.0;
	float amp = 2.0;
	for(int a = 0; a < 6; a++)
	{
		result += derivative(xDir[a] * x + yDir[a] * z, freq, speeds[a], amp, t);
		freq *= 2.0;
		amp *= 0.8;
	}
	return result;
}


void main() {
    uvec2 gid = gl_GlobalInvocationID.xy;
    for(int i = 0; i < 16; i++)
    {
        for(int j = 0; j < 16; j++)
        {
            uvec2 offsetGid = uvec2(gid.x * 8 + i, gid.y * 8 + j);

            uint index = offsetGid.y * int(size.size.x) + offsetGid.x;

            if (index >= size.size.x * size.size.x) {
                return;
            }
            vec4 old_val = imageLoad(dest_image, ivec2(offsetGid));
            vec4 out_val = vec4(0,0,0,0);

            float nx = (offsetGid.x/(size.size.x*2)) * 511;
            float ny = (offsetGid.y/size.size.x) * 255;

            if(abs(totalDerivative(nx,ny,time.time.x)) < 0.5 && totalDerivative(nx,ny,time.time.x - 0.5) > 0.0 && totalDerivative(nx,ny,time.time.x + 0.5) < 0.0)
            {
                out_val = vec4(1,1,1,old_val.w + 0.1);
            }
            else
            {
                out_val = vec4(1,1,1,old_val.w * 0.95);
            }
            vec3 pos = positions.data[index];

            imageStore(dest_image, ivec2(offsetGid), out_val);
        }
    }
}