extends Node3D

const CHUNK_SIZE = 20
const SUBDIVISIONS = 10 # 2 units per vertex for low poly look
const HEIGHT_SCALE = 5.0
const TREE_CHANCE = 0.05

var chunk_pos: Vector2
var noise: FastNoiseLite

@onready var mesh_instance = MeshInstance3D.new()
@onready var static_body = StaticBody3D.new()
@onready var collision_shape = CollisionShape3D.new()


func _ready():
	add_child(mesh_instance)
	mesh_instance.add_child(static_body)
	static_body.add_child(collision_shape)
	
	# Load grass texture
	var grass_tex = load("res://public/grass/Grass1.jpg")
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = grass_tex
	mat.uv1_scale = Vector3(10, 10, 10)
	mesh_instance.material_override = mat

func generate(c_pos: Vector2, n: FastNoiseLite):
	chunk_pos = c_pos
	noise = n
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var step = float(CHUNK_SIZE) / SUBDIVISIONS
	var offset_x = chunk_pos.x * CHUNK_SIZE
	var offset_z = chunk_pos.y * CHUNK_SIZE
	
	# Create vertices
	var vertices = []
	for z in range(SUBDIVISIONS + 1):
		for x in range(SUBDIVISIONS + 1):
			var world_x = offset_x + x * step
			var world_z = offset_z + z * step
			# Height from noise
			var y = noise.get_noise_2d(world_x, world_z) * HEIGHT_SCALE
			var uv = Vector2(float(x) / SUBDIVISIONS, float(z) / SUBDIVISIONS)
			
			st.set_uv(uv)
			st.add_vertex(Vector3(x * step, y, z * step))
			
			# Chance to spawn a tree
			if x < SUBDIVISIONS and z < SUBDIVISIONS:
				var rand_val = hash(Vector3(world_x, world_z, 0)) % 100
				if rand_val < (TREE_CHANCE * 100):
					spawn_tree(Vector3(x * step, y, z * step))

	# Create indices
	for z in range(SUBDIVISIONS):
		for x in range(SUBDIVISIONS):
			var i = x + z * (SUBDIVISIONS + 1)
			# Triangle 1
			st.add_index(i)
			st.add_index(i + 1)
			st.add_index(i + SUBDIVISIONS + 1)
			# Triangle 2
			st.add_index(i + 1)
			st.add_index(i + SUBDIVISIONS + 2)
			st.add_index(i + SUBDIVISIONS + 1)
			
	st.generate_normals()
	
	var mesh = st.commit()
	mesh_instance.mesh = mesh
	collision_shape.shape = mesh.create_trimesh_shape()

func spawn_tree(local_pos: Vector3):
	# Using PackedScene of Tree.obj
	var tree = PackedScene.new()
	tree = load("res://public/tree/Tree.obj")
	var instance = tree.instantiate() as Node3D
	add_child(instance)
	instance.position = local_pos
