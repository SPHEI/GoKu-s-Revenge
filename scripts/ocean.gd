extends MeshInstance3D
@export var density = 1.0;
func _ready():
	# Create vertices
	var vertices = PackedVector3Array()
	var increment = 1.0/density
	
	var start = -75.0 * density
	var end = 75.0 * density
	
	var n = start * 2
	while n < end * 2:
		var m = start
		while m < end:
			var n1 = n/density
			var n2 = (n + 1.0)/density
			var m1 =  m/density
			var m2 = (m + 1.0)/density
			vertices.push_back(Vector3(n1, 0, m1))
			vertices.push_back(Vector3(n2, 0, m1))
			vertices.push_back(Vector3(n1, 0, m2))
			
			vertices.push_back(Vector3(n2, 0, m1))
			vertices.push_back(Vector3(n2, 0, m2))
			vertices.push_back(Vector3(n1, 0, m2))
			m += increment
		n += increment
	# Create mesh arrays
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	# Create ArrayMesh and assign to this MeshInstance3D
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh = arr_mesh
