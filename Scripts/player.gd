extends CharacterBody3D

#Signal that tells the sticky what to do
signal shoot_hook

const SPEED = 5.0
const JUMP_VELOCITY = 8
var impulse_strength = 400

var sensivity = 0.003
var onCooldown = false
var hook = false
#Cordinates that dictate to where the player should move
var angle : Vector3
var hit = false
var hookChords : Vector3
var oldVelo = 0
var lastInput = Input.get_vector("left", "right", "up", "down")

var hp = 100
var maxHp = 100

@onready var camera = $Camera3D
#@onready var hookAnimation = $HookAnimation
@onready var hookCooldown = $HookCooldown

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _shoot_hook() -> void:
	if Input.is_action_just_pressed("hook") and !onCooldown:
		#hookAnimation.play("ShootHook")
		onCooldown = true
		hookCooldown.start()
		shoot_hook.emit("shoot")
		hook = true
		print("shoot")
	if Input.is_action_pressed("hook") and hook:
		if hit:
			angle = position.direction_to(hookChords)
			velocity = angle * impulse_strength * get_physics_process_delta_time()
			if impulse_strength < 1200:
				impulse_strength += 10
		hookCooldown.start()
	if Input.is_action_just_released("hook") and hook:
		hook = false
		shoot_hook.emit("retract")
		print("retract")

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensivity)
		camera.rotate_x(-event.relative.y * sensivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(_delta: float) -> void:
	_shoot_hook()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		lastInput = input_dir
	print(lastInput)
	var direction := (transform.basis * Vector3(lastInput.x, 0, lastInput.y)).normalized()
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var target_velocity := direction * SPEED
	if is_on_floor():
		angle = Vector3.ZERO
		lastInput = Vector2.ZERO
		horizontal_velocity = target_velocity
		impulse_strength = 400
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
	
	# Add the gravity.
	if Input.is_action_pressed("hook") and hook and hit:
		pass
		#velocity.y = 0
	elif not is_on_floor() and velocity.y > -100:
		velocity += get_gravity() * delta * 2

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
	move_and_slide()

func _on_hook_cooldown_timeout() -> void:
	hit = false
	shoot_hook.emit("reset")
	onCooldown = false
	print("reset")

func _on_hook_gun_2_hook_hit(cords,hitted) -> void:
	hookChords = cords
	if hitted:
		hit = true
