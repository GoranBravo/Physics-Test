extends Node3D

#import location = $Player.position

#var chunk location.getChunk()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if chunkIsSaved:
		#loadChunk(chunk)
	#else:
		#addChilde("{chunk(0)}_{chunk(1)}" = MeshInstance3D.new())
		#
	pass

func _getChunk(pos: float) -> int:
	return 1
