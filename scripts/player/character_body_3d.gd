extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const SENSITIVITY = 0.003
const BOB_FREQ = 3.0
const BOB_AMP = 0.01
const GRAVITY = 16.0
const TERMINAL_VELOCITY = 26.0

var t_bob := 0.0
var current_gravity := 12.0

@onready var camera: Camera3D = $Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity
	if is_on_floor():
		current_gravity = GRAVITY
	else:
		current_gravity = clamp(pow(current_gravity, 1.01), GRAVITY, TERMINAL_VELOCITY)
		velocity += Vector3.DOWN * current_gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
		t_bob = 0

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 1.5) * BOB_AMP
	return pos
