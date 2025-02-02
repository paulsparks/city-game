extends CharacterBody3D
class_name PlayerController

const SPEED = 3.5
const JUMP_VELOCITY = 4.0
const SENSITIVITY = 0.003
const BOB_FREQ = 3.0
const BOB_AMP = 0.01
const GRAVITY = 16.0
const TERMINAL_VELOCITY = 26.0
const REACH_DISTANCE = 2

var t_bob := 0.0
var current_gravity := 12.0
var held_prop: Prop = null
var held_prop_mesh: MeshInstance3D = null

@onready var camera: Camera3D = $Camera3D
@onready var wallet: WalletComponent = $WalletComponent


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


func _process(_delta):
	_handle_raycast()


func _handle_raycast() -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE
	var hold_pos = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE / 2
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result: Dictionary = space_state.intersect_ray(query)
	var collider = result.get("collider")
	
	if held_prop != null:
		held_prop.position = hold_pos
		if Input.is_action_just_pressed("interact"):
			held_prop.freeze = false
			held_prop = null
	else:
		match collider:
			collider when collider is Prop: _handle_prop_pickup(collider)
			#collider when collider is ShoppingCart: _handle_shopping_cart(collider)


func _handle_prop_pickup(prop: Prop) -> void:	
	if Input.is_action_just_pressed("interact"):
		held_prop = prop
		held_prop.freeze = true
