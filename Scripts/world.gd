extends Node3D

#Array of loaded chunks
var chunkNodes : Array[MeshInstance3D] = [MeshInstance3D.new()]

#Loads the noise
var noisePreset : FastNoiseLite = load("res://Sprites/noiseImage.tres")
var chunkGenerationScript : Script = load("res://Scripts/chunk.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_loadChunks()

# Takes a two point coordinate and returns the chunk in which is the player and all around him
func _getChunk(coords: Vector2) -> Array[Array]:
	# Initializes the response array
	var nineChunks:Array[Array] = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]
	# Array to get the player chunk, and the eight surrounding ones
	var chunkModifier : Array[Array] = [[1,1],[1,2],[2,1],[2,2],[1,0],[0,1],[2,0],[0,2],[0,0]]
	for chunkNumber in 9:
		nineChunks[chunkNumber][0] = int(coords.x/128)
		nineChunks[chunkNumber][1] = int(coords.y/128)
		if coords.x <= 0:
			nineChunks[chunkNumber][0] -= chunkModifier[chunkNumber][0]
		else:
			nineChunks[chunkNumber][0] += chunkModifier[chunkNumber][0]
		if coords.y <= 0:
			nineChunks[chunkNumber][1] -= chunkModifier[chunkNumber][1]
		else:
			nineChunks[chunkNumber][1] += chunkModifier[chunkNumber][1]
			
		if nineChunks[chunkNumber][0] == 0:
			if nineChunks[0][0] == 1:
				nineChunks[chunkNumber][0] = -1
			else:
				nineChunks[chunkNumber][0] = 1
		if nineChunks[chunkNumber][1] == 0:
			if nineChunks[0][1] == 1:
				nineChunks[chunkNumber][1] = -1
			else:
				nineChunks[chunkNumber][1] = 1
	return nineChunks

func _loadChunks() -> void:
	# Get the position of the player
	var playerPosition:Vector3 = get_node("Player").position
	# Get the chunk in where the player is
	var playerChunks:Array[Array] = _getChunk(Vector2(playerPosition.x, playerPosition.z))
	# If the player is in the same chunk
	if int(chunkNodes[0].position.x) == playerChunks[0][0]*128 and int(chunkNodes[0].position.z) == playerChunks[0][1]*128:
		pass
	else:
		# If the player is not in the same chunk
		var chunkLoaded : bool = false
		for i in playerChunks:
			chunkLoaded = false
			for e in chunkNodes: #TODO: This is no good, it should know where you are going and only generate the new chunks
				if e.name == str(i):
					chunkLoaded = true
			if !chunkLoaded:
				var newChunk : MeshInstance3D = MeshInstance3D.new()
				newChunk.name = str(i)
				newChunk.position.x = (i[0])*128
				newChunk.position.z = (i[1])*128
				newChunk.set_script(chunkGenerationScript)
				noisePreset.offset = Vector3((i[0])*128,(i[1])*128,0)
				newChunk.noise = noisePreset
				add_child(newChunk)
				chunkNodes.append(newChunk)
				print(chunkNodes)
