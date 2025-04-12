extends MeshInstance3D
func _ready():
	var size = 256
	
	var vertices = PackedVector3Array()
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
