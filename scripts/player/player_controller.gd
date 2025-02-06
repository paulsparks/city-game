extends CharacterBody3D
class_name PlayerController

const WALK_SPEED = 4.5
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 7.0
const SENSITIVITY = 0.003
const BOB_FREQ = 3.0
const BOB_AMP = 0.01
const GRAVITY = 25.0
const TERMINAL_VELOCITY = 35.0
const REACH_DISTANCE = 3

var speed = WALK_SPEED
var t_bob := 0.0
var current_gravity := 12.0
var held_prop: Prop = null
var held_prop_mesh: MeshInstance3D = null
var can_stand: bool = true

@onready var camera: Camera3D = $Camera3D
@onready var wallet: WalletComponent = $WalletComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var top_half_1: CollisionShape3D = $TopHalf1
@onready var top_half_2: CollisionShape3D = $TopHalf2


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
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
		t_bob = 0

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob) + (Vector3(0,1,0) if (can_stand and not Input.is_action_pressed("crouch")) else Vector3(0, 0.2, 0))

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"):
		top_half_1.disabled = true
		top_half_2.disabled = true
		speed = CROUCH_SPEED


func _headbob(time) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 1.5) * BOB_AMP
	return pos


func _process(_delta):
	if can_stand and not Input.is_action_pressed("crouch"):
		top_half_1.disabled = false
		top_half_2.disabled = false
		speed = WALK_SPEED
	_handle_raycast()
	

func _handle_raycast() -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE
	var hold_pos = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE / 2
	var place_pos = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE / 3
	var query = PhysicsRayQueryParameters3D.create(origin, end, 2)
	var result: Dictionary = space_state.intersect_ray(query)
	var collider = result.get("collider")
	
	if Input.is_action_just_pressed("use"):
		var item = inventory.equipped
		match item:
			item when item is Bag: inventory.place_bag(place_pos, self)
	if Input.is_action_just_pressed("use_special"):
		var item = inventory.equipped
		match item:
			item when item is Bag: inventory.place_next_bag_item(place_pos, self)
	
	if held_prop != null:
		held_prop.position = hold_pos
		held_prop.rotation.y = rotation.y
		held_prop.rotation.x = camera.rotation.x
		if Input.is_action_just_pressed("interact"):
			held_prop.freeze = false
			held_prop = null
	else:
		if Input.is_action_just_pressed("interact"):
			match collider:
				collider when collider is Prop: _handle_prop_pickup(collider)
				collider when collider is Trigger: collider.perform_task()
		if Input.is_action_just_pressed("pocket"):
			match collider:
				collider when collider is Bag: inventory.add_to_inventory(collider)


func _handle_prop_pickup(prop: Prop) -> void:
		held_prop = prop
		held_prop.freeze = true


func _on_top_half_area_body_entered(body: Node3D) -> void:
	if not body is PlayerController:
		can_stand = false


func _on_top_half_area_body_exited(body: Node3D) -> void:
	if not body is PlayerController:
		can_stand = true
