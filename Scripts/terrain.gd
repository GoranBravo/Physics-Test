@tool
extends MeshInstance3D

#Size of the mesh
const size := 256.0

#More resolution indicates a more detailed mesh
@export_range(4, 256, 4) var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()

#Image noise from where the mesh is made
@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()

#Maximun height of the mesh
@export_range(4.0, 128.0, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		material_override = load("res://Sprites/shaderWorld.tres")
		material_override.set_shader_parameter("height", height * 2.0)
		update_mesh()

#Gives collision when the mesh is loaded correctly
func _ready() -> void:
	update_mesh()

#Returns the float value of the "height" of the noise in a given point
func get_height(x: float, y: float) -> float:
	return noise.get_noise_2d(x, y) * height

#Returns normalized coordintes of a point given, with its cooresponding height
func get_normal(x: float, y: float) -> Vector3:
	var epsilon := size / resolution
	var normal := Vector3(
		(get_height(x + epsilon, y) - get_height(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(get_height(x, y + epsilon) - get_height(x, y - epsilon)) / (2.0 * epsilon)
	)
	return normal.normalized()

#When a chage in the parameters is made, this function updates the mesh form
func update_mesh() -> void:
	#Creates a plane with the size given
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)
	
	#Creates the array mesh with the plane and the height of the noise
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i:int in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		if noise:
			vertex.y = get_height(vertex.x, vertex.z)
			normal = get_normal(vertex.x, vertex.z)
			tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z
	
	var array_mesh := ArrayMesh.new()
	#Creates the mesh with triangles and the coordintes of the array mesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh
	update_collision()

#Creates the colsion creating polygons ecuals the triangles
func update_collision() -> void:
	var Body = StaticBody3D.new()
	var TerrainCollision = CollisionShape3D.new()
	
	Body.set_collision_layer_value(2,true)
	Body.set_collision_mask_value(2,true)
	add_child(Body)
	
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces())
	TerrainCollision.set_shape(shape)
	Body.add_child(TerrainCollision)
