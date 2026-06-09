extends Node3D

@export var player: Node3D
@export var chunk_radius: int = 2

var chunk_scene = preload("res://scenes/chunk.tscn")
var noise = FastNoiseLite.new()
var active_chunks = {}
var chunk_size = 20.0

func _ready():
	noise.seed = randi()
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.frequency = 0.02
	
	if player == null:
		player = get_parent().get_node("Player")
	
	update_chunks()

func _process(_delta):
	update_chunks()

func update_chunks():
	if player == null:
		return
		
	var player_chunk_x = floor(player.global_position.x / chunk_size)
	var player_chunk_z = floor(player.global_position.z / chunk_size)
	var current_chunk = Vector2(player_chunk_x, player_chunk_z)
	
	var visible_chunks = []
	
	for x in range(-chunk_radius, chunk_radius + 1):
		for z in range(-chunk_radius, chunk_radius + 1):
			visible_chunks.append(current_chunk + Vector2(x, z))
			

	for c_pos in visible_chunks:
		if not active_chunks.has(c_pos):
			var chunk = chunk_scene.instantiate()
			add_child(chunk)
			chunk.position = Vector3(c_pos.x * chunk_size, 0, c_pos.y * chunk_size)
			chunk.generate(c_pos, noise)
			active_chunks[c_pos] = chunk
			

	var keys_to_remove = []
	for c_pos in active_chunks.keys():
		if not visible_chunks.has(c_pos):
			active_chunks[c_pos].queue_free()
			keys_to_remove.append(c_pos)
			
	for c_pos in keys_to_remove:
		active_chunks.erase(c_pos)
