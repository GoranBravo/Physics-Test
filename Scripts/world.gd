extends Node3D

var chunky = MeshInstance3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_loadChunks()

func _getChunk(coords: Vector2) -> Array[float]:
	var chunk:Array[float] = [0,0]
	if coords.x <= 0:
		chunk[0] -= 1
	else:
		chunk[0] += 1
	if coords.y <= 0:
		chunk[1] -= 1
	else:
		chunk[1] += 1
	return chunk

func _loadChunks() -> void:
	var playerPosition:Vector3 = get_node("Player").position
	var playerChunk:Array[float] = _getChunk(Vector2(playerPosition.x, playerPosition.z))
	#var resC:String = str(playerChunk)
	if chunky.position.x == playerChunk[0]*128 and chunky.position.z == playerChunk[1]*128:
		pass
	else:
		chunky.position.x = playerChunk[0]*128
		chunky.position.z = playerChunk[1]*128
		chunky.set_script(load("res://Scripts/terrain.gd"))
		var nose = load("res://Sprites/noiseImage.tres")
		nose.offset = Vector3(playerChunk[0]*128,playerChunk[1]*128,0)
		chunky.noise = nose
		chunky.height = 64
		add_child(chunky)
