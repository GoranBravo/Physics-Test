extends CharacterBody3D

#Signal that tells the player the coords of the sticky when it has hit something
signal hook_hit

#Force of the hook shot
const HOOK_FORCE = 100
#Streght of the aproximation of the cordinates
const SNAP_RANGE = Vector3(2,2,2)
#Position of the sticky relative to the center of the player
const LOCAL_POSITION = Vector3(0.409, -0.275, -0.677)
#Limit force of the sticky when shot
const STICKY_MAX_FORCE = 1500

#Cordinates that dictate to where the sticky should move
var angle : Vector3
#Variable that activates the movment of the sticky when shot
var hookHasShooted = false
#Variable that activates the movment of the sticky when it has to return to the player
var retract = false
#Acumulative force of the sticky when retract
var retractForce = 1000

#Calls the player camera
@onready var camera = $".."
#Calls the timer of the hook
@onready var hookCooldown = $"../../HookCooldown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

#Runs the physics
func _physics_process(delta: float) -> void:
	#Moves the stcky when shot
	if hookHasShooted:
		#Moves the sticky until it hits something, when it hits, stops the movment and emits its position
		if move_and_collide(angle*HOOK_FORCE*delta):
			hookHasShooted = false
			hook_hit.emit(get_position())
		#Adds gravity to the sticky when shot
		angle += get_gravity() * delta / 10
	#Moves the sticky when retracted
	elif retract:
		#Defines the movment of the sticker to the position of the player
		velocity = position.direction_to(_playerHookSticky_position())*retractForce*delta
		#Adds gravity to the sticky when retracting
		velocity += get_gravity() * delta * 50

		#Runs the movment
		move_and_slide()

		#Accelerates the sticky to a maximum
		if retractForce > STICKY_MAX_FORCE:
			retractForce += 50
		#Aproximates the global coordinates from where the sticky should return and from where it is
		var originSnapped = _playerHookSticky_position().snapped(SNAP_RANGE)
		var positionSnapped = position.snapped(SNAP_RANGE)
		#If the sticky is close enough to its original position, instant reset its position
		if positionSnapped == originSnapped:
			_retract_end()
			#Resets the cooldown of the hook
			hookCooldown.timeout.emit()

func _playerHookSticky_position() -> Vector3:
	#Records the global position of the sticky
	var lastPos = position
	var hookPosition : Vector3
	#Momentary returns the sticky to player coordinates
	top_level = false
	#Teleports the sticky to the player hook
	position = LOCAL_POSITION
	#Stores the global position of the sticky when in the hook
	hookPosition = global_position
	#Removes the sticky from the player coordinates
	top_level = true
	#Returns the sticky to where it should be (XD)
	position = lastPos
	return hookPosition

func _retract_end() -> void:
	#Stops the movment of the sticky
	retract = false
	#Moves the sticky to original position and saves its position	
	global_position = _playerHookSticky_position()
	#Returns the sticky to player coordinates
	top_level = false
	#Resets the end force
	retractForce = 1000


#Function vinculated to the shoot_hook signal from the player script
func _on_player_shoot_hook(hookState: String) -> void:
	#If the player shoot the hook
	if hookState == "shoot":
		#Get the position to where the player was looking
		angle = Vector3(-camera.get_global_transform().basis.z)
		#De-attach the sticky from the player coordinates
		top_level = true
		#Indicate that the sticky should move
		hookHasShooted = true
	#If the hook has been retracted, after some time, instant reset the position of the sticky
	elif hookState == "reset" and retract == true:
		_retract_end()
	#If the player realese the hook
	elif hookState == "retract":
		#Stops the shooting movment if it wasnt stopped yet
		hookHasShooted = false
		#Starts the retracting movment
		retract = true
