extends CharacterBody3D

#Signal that tells the sticky what to do
signal shoot_hook

#Speed at which the player moves
const SPEED = 5.0
#Jump force of the player
const JUMP_VELOCITY = 8

#Force applied to the player movment when using the hook
var hookImpulseStrength = 400
#Speed at which the player camera moves
var cameraSensivity = 0.003
#Dictates if the hook can be shot again
var hookOnCooldown = false
#If true, the hook has been shot
var hookInMovment = false
#Cordinates that dictate to where the player should move
var angle : Vector3
#If true, the sticky has landed something
var hit = false
#Coordinates of where the sticky is when landed
var stickyCords : Vector3
#Records the last input given by the player
var lastMovInput = Input.get_vector("left", "right", "up", "down")

#Calls the camera
@onready var camera = $Camera3D
#Calls the animation of the hook
# @onready var hookAnimation = $HookAnimation
#Calls the timer of the hook
@onready var hookCooldown = $HookCooldown

#Changes the mouse mode to control the camera
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#Controls the hook
func _hook() -> void:
	#If the player wants to shoot the hook and its not on cooldown
	if Input.is_action_just_pressed("hook") and !hookOnCooldown:
		#Play the hook shooting animation
		#hookAnimation.play("ShootHook")
		#Stop the player from shooting the hook again
		hookOnCooldown = true
		#Start running the timer of the cooldown
		hookCooldown.start()
		#Send the signal telling the hook has been shot
		shoot_hook.emit("shoot")
		#Starts the hook movment
		hookInMovment = true
		print("shoot")
	#If the player wants to retract the hook
	if Input.is_action_just_released("hook") and hookInMovment:
		#Stops the hook movment
		hookInMovment = false
		#Stops the movment of the player by the hook
		hit = false
		#Tells the sticky to retract
		shoot_hook.emit("retract")
		print("retract")

#Handles the camera movment
func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * cameraSensivity)
		camera.rotate_x(-event.relative.y * cameraSensivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

#Runs the game functions
func _process(_delta: float) -> void:
	_hook()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

#Runs the physics
func _physics_process(delta: float) -> void:
	#Get the input direction and handle the movement/deceleration.
	var inputDir := Input.get_vector("left", "right", "up", "down")
	if inputDir != Vector2.ZERO:
		lastMovInput = inputDir
	var direction := (transform.basis * Vector3(lastMovInput.x, 0, lastMovInput.y)).normalized()
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var target_velocity := direction * SPEED
	if is_on_floor():
		angle = Vector3.ZERO
		lastMovInput = Vector2.ZERO
		horizontal_velocity = target_velocity
		hookImpulseStrength = 400
	else:
		horizontal_velocity = horizontal_velocity.move_toward(
			target_velocity,
			4 * SPEED * delta
		)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	# print(angle, "angle")
	# print(direction, "direction")
	# print(velocity, "velo")
	
	#Adds the gravity.
	if not is_on_floor() and velocity.y > -100:
		velocity += get_gravity() * delta * 2

	#Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY

	#Defines the movment of the player to the position of wher the sticky has hit something
	if hit:
		angle = position.direction_to(stickyCords)
		velocity = angle * hookImpulseStrength * get_physics_process_delta_time()
		#Slowly increse the force at witch the player is draged by the hook to a limit
		if hookImpulseStrength < 1200:
			hookImpulseStrength += 10

	#Runs the movment
	move_and_slide()

#Activate when the timer runs out
func _on_hook_cooldown_timeout() -> void:
	#Tells the sticky that the timer has ended
	shoot_hook.emit("reset")
	#Reset the cooldown of the hook
	hookOnCooldown = false
	print("reset")

#Activate when the sticky hit something
func _on_hook_gun_2_hook_hit(cords) -> void:
	stickyCords = cords
	#Starts the player movment towards the sticky
	hit = true
