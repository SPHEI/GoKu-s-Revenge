extends MeshInstance3D

var vertices = PackedVector3Array()
#@export var foamResolution = 256.0
#Don't turn this on or your pc will burn
#@export var computeFoam = false
#@export var foamFps = 60;
func _ready():
	var size = 256
	var indices = PackedInt32Array()
	
	for n in range(size*2):
			for m in range(size):
				vertices.push_back(Vector3(n, 0, m))
	for n in range(size*2-1):
		for m in range(size-1):
			var tl = n * size + m         
			var tre = tl + 1                    
			var bl = (n + 1) * size + m    
			var br = bl + 1                  
			indices.push_back(tl)
			indices.push_back(bl)
			indices.push_back(tre)
			
			indices.push_back(tre)
			indices.push_back(bl)
			indices.push_back(br)
			
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh = arr_mesh
	
	mesh.set_custom_aabb(mesh.get_aabb().grow(1000.0))
	position += Vector3(255,0,128)
	
	material_override.set_shader_parameter("use_foam_texture", false)
	
	'''
	#This is my amazing fucking attempt at making a compute shader
	#MAYBE reaches 20fps with a 1024 resolution (the minimum for it to look good).
	#Apparently godot can't pass textures GPU->GPU meaning the only way is GPU->CPU-GPU, which kills any performance gain from compute shaders.
	
	material_override.set_shader_parameter("use_foam_texture", computeFoam)
	if computeFoam:
		var img_format = RDTextureFormat.new()
		img_format.width = foamResolution*2
		img_format.height = foamResolution
		img_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
		img_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
		img_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT |
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT |
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT |
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
		)
		rd = RenderingServer.create_local_rendering_device()
		
		image_texture = rd.texture_create(img_format, RDTextureView.new())
		
		var shader_file := load("res://shaders/foam.glsl")
		var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
		shader = rd.shader_create_from_spirv(shader_spirv)
		
		time_buffer = rd.uniform_buffer_create(16)  # 4 bytes for one float
		
		var input_bytes = vertices.to_byte_array()
		var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
		# Create a uniform to assign the buffer to the rendering device
		uniformImg = RDUniform.new()
		uniformImg.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniformImg.binding = 0 # this needs to match the "binding" in our shader file
		uniformImg.add_id(image_texture)
		
		
		uniform = RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		uniform.binding = 1 # this needs to match the "binding" in our shader file
		uniform.add_id(buffer)
		
		time_uniform = RDUniform.new()
		time_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		time_uniform.binding = 2
		
		
		var bytes2 = PackedByteArray()
		bytes2.resize(16)
		bytes2.encode_float(0, foamResolution)
		
		var size_buffer = rd.uniform_buffer_create(16)  # 4 bytes for one float
		rd.buffer_update(size_buffer,0,16,bytes2)
		
		size_uniform = RDUniform.new()
		size_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
		size_uniform.binding = 3
		size_uniform.add_id(size_buffer)
		
		pipeline = rd.compute_pipeline_create(shader)
		foam_image = Image.create(foamResolution*2, foamResolution, false, Image.FORMAT_RGBAF)
		img_tex = ImageTexture.create_from_image(foam_image)
		material_override.set_shader_parameter("foam_texture", img_tex)
	
var rd: RenderingDevice
var shader: RID
var time_buffer: RID
var uniform: RDUniform
var uniformImg: RDUniform
var time_uniform: RDUniform
var size_uniform: RDUniform
var pipeline: RID
var image_texture: RID

var frame_count = 0.0
func _process(delta: float):
	frame_count += delta;
	if computeFoam:
		if frame_count >= 1.0/foamFps:
			frame_count = 0.0;
			updateFoam()
var foam_image
var img_tex 
func updateFoam():
	var float_time = Time.get_ticks_msec()/1000.0 - 0.5
	var bytes = PackedByteArray()
	bytes.resize(16)
	bytes.encode_float(0, float_time)
			
	rd.buffer_update(time_buffer,0,16,bytes)
			
	time_uniform.clear_ids()
	time_uniform.add_id(time_buffer)
			
	var uniform_set := rd.uniform_set_create([uniform,uniformImg, time_uniform, size_uniform], shader, 0)
			
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, (foamResolution/4)/8, (foamResolution/8)/8, 1)
	rd.compute_list_end()
	
	var buffer2 := rd.texture_get_data(image_texture, 0) #<------------------------------------this alone cuts fps by like 1/4 fuck me
	#print("Image Size: ", foam_image.get_width(), "x", foam_image.get_height())
	#print("Texture Size: ", img_tex.get_width(), "x", img_tex.get_height())
	foam_image.set_data(foamResolution*2, foamResolution, false, Image.FORMAT_RGBAF, buffer2)
	img_tex.update(foam_image)
	'''
