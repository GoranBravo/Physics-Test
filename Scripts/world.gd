extends Node3D

#Array of loaded chunks
var chunkys : Array[MeshInstance3D] = [MeshInstance3D.new()]

#Loads the noise
var nose : FastNoiseLite = load("res://Sprites/noiseImage.tres")
var chunkGenerationScript : Script = load("res://Scripts/chunk.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_loadChunks()

#Takes a two point coordinate and returns the chunk in which is the player and all around him
func _getChunk(coords: Vector2) -> Array[Array]:
	var chunk:Array[Array] = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]
	var numebersMason : Array[Array] = [[1,1],[1,2],[2,1],[2,2],[1,0],[0,1],[2,0],[0,2],[0,0]]
	for i in 9:
		chunk[i][0] = int(coords.x/128)
		chunk[i][1] = int(coords.y/128)
		if coords.x <= 0:
			chunk[i][0] -= numebersMason[i][0]
		else:
			chunk[i][0] += numebersMason[i][0]
		if coords.y <= 0:
			chunk[i][1] -= numebersMason[i][1]
		else:
			chunk[i][1] += numebersMason[i][1]
			
		if chunk[i][0] == 0:
			if chunk[0][0] == 1:
				chunk[i][0] = -1
			else:
				chunk[i][0] = 1
		if chunk[i][1] == 0:
			if chunk[0][1] == 1:
				chunk[i][1] = -1
			else:
				chunk[i][1] = 1
	return chunk

func _loadChunks() -> void:
	#Get the position of the player
	var playerPosition:Vector3 = get_node("Player").position
	#Get the chunk in where the player is
	var playerChunk:Array[Array] = _getChunk(Vector2(playerPosition.x, playerPosition.z))
	#If the player is in the same chunk
	if int(chunkys[0].position.x) == playerChunk[0][0]*128 and int(chunkys[0].position.z) == playerChunk[0][1]*128:
		pass
	else:
		#If the player is not in the same chunk
		for i in playerChunk:
			var chunkInPlay : MeshInstance3D = MeshInstance3D.new()
			chunkInPlay.name = str(i)
			chunkInPlay.position.x = (i[0])*128
			chunkInPlay.position.z = (i[1])*128
			print(chunkInPlay.position)
			chunkInPlay.set_script(chunkGenerationScript)
			nose.offset = Vector3((i[0])*128,(i[1])*128,0)
			chunkInPlay.noise = nose
			if i == playerChunk[0]:
				chunkys = []
			add_child(chunkInPlay)
			chunkys.append(chunkInPlay)
