extends CharacterBody3D

#Cordinates that dictate to where the sticky should move
var angle : Vector3
#Variable that activates the movment of the sticky when shoot
var hookShot = false
#Variable that activates the movment of the sticky when it has to return to the player
var retract = false
#Acumulative force of the sticky when shoot
var hookStartForce = 100
#Acumulative force of the sticky when retract
var hookEndForce = 1000

#Streght of the aproximation of the cordinates
const snapCordsValue = Vector3(2,2,2)
#Position of the sticky relative to the center of the player
const localPosition = Vector3(0.409, -0.275, -0.677)
#Limit force of the sticky when shoot
const hookMaxEndForce = 1500

signal hook_hit

@onready var camera = $".."
@onready var hookCooldown = $"../../HookCooldown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if hookShot:
		if move_and_collide(angle*hookStartForce*delta):
			hookShot = false
			hook_hit.emit(get_position(),true)
		else:
			if hookStartForce > 0:
				hookStartForce -= 1
			hook_hit.emit(get_position(),false)
		if top_level == true:
			angle += get_gravity() * delta / 10
	elif retract:
		angle = position.direction_to(_actualize_playerHook_position())
		velocity = angle*hookEndForce*delta
		if hookEndForce > hookMaxEndForce:
			hookEndForce += 50
		move_and_slide()
		#Aproximates the global coordinates from where the sticky should return and from where it is
		var originSnapped = _actualize_playerHook_position().snapped(snapCordsValue)
		var positionSnapped = position.snapped(snapCordsValue)
		#If the sticky is close enough to its original position, instant reset its position
		if positionSnapped == originSnapped:
			_retract_end()
			#Resets the cooldown of the hook
			hookCooldown.timeout.emit()

func _actualize_playerHook_position() -> Vector3:
	#Records the global position of the sticky
	var lastPos = position
	var playerHook : Vector3
	#Momentary returns the sticky to player coordinates
	top_level = false
	#Teleports the sticky to the player hook
	position = localPosition
	#Stores the global position of the sticky when in the hook
	playerHook = global_position
	#Removes the sticky from the player coordinates
	top_level = true
	#Returns the sticky to where it should be (XD)
	position = lastPos
	return playerHook

func _retract_end() -> void:
	#Stops the movment of the sticky
	retract = false
	#Moves the sticky to original position and saves its position	
	global_position = _actualize_playerHook_position()
	#Returns the sticky to player coordinates
	top_level = false
	#Resets both forces
	hookStartForce = 100
	hookEndForce = 1000


#Function vinculated to the shoot_hook signal from the player script
func _on_player_shoot_hook(hook: String) -> void:
	#If the player shoot the hook
	if hook == "shoot":
		#Get the position to where the player was looking
		angle = Vector3(-camera.get_global_transform().basis.z)
		#De-attach the sticky from the player coordinates
		top_level = true
		#Indicate that the sticky should move
		hookShot = true
	#If the hook has been retracted, after some time, instant reset the position of the sticky
	elif hook == "reset" and retract == true:
		_retract_end()
	#If the player realese the hook
	elif hook == "retract":
		#Stops the shooting movment if it wasnt stopped yet
		hookShot = false
		#Starts the retracting movment
		retract = true
