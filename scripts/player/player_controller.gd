class_name PlayerController
extends CharacterBody3D

const WALK_SPEED: float = 4.5
const CROUCH_SPEED: float = 2.5
const JUMP_VELOCITY: float = 7.0
const SENSITIVITY: float = 0.003
const BOB_FREQ: float = 3.0
const BOB_AMP: float = 0.01
const GRAVITY: float = 25.0
const TERMINAL_VELOCITY: float = 35.0
const REACH_DISTANCE: float = 3
const ITEM_SCROLL_ROTATE_SPEED: float = 0.2

var speed: float = WALK_SPEED
var t_bob: float = 0.0
var current_gravity: float = 12.0
var held_prop: Prop = null
var held_prop_mesh: MeshInstance3D = null
var can_stand: bool = true
var held_prop_y_rotation: Variant = null

var hand_ray: Dictionary = {"collider": null, "hold_pos": null}

@onready var camera: Camera3D = $Camera3D
@onready var wallet: WalletComponent = $WalletComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var top_half_1: CollisionShape3D = $TopHalf1
@onready var top_half_2: CollisionShape3D = $TopHalf2


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if PlayerUi.inventory_opened:
		return

	if event is InputEventMouseButton:
		if held_prop:
			if event.is_action_pressed("scroll_up"):
				_scroll_to_rotate(-ITEM_SCROLL_ROTATE_SPEED)
			if event.is_action_pressed("scroll_down"):
				_scroll_to_rotate(ITEM_SCROLL_ROTATE_SPEED)

	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event

		rotate_y(-mouse_motion.relative.x * SENSITIVITY)
		camera.rotate_x(-mouse_motion.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		return


func _unhandled_key_input(event: InputEvent) -> void:
	if PlayerUi.inventory_opened:
		return

	if event is not InputEventKey:
		return

	# When hand_ray is fully populated and a prop is not being held
	if not held_prop and not hand_ray.values().has(null):
		if event.is_action_pressed("interact"):
			match hand_ray.collider:
				hand_ray.collider when hand_ray.collider is Prop:
					var prop: Prop = hand_ray.collider
					_handle_prop_pickup(prop)

				hand_ray.collider when hand_ray.collider is Trigger:
					var trigger: Trigger = hand_ray.collider
					trigger.perform_task()

		if event.is_action_pressed("pocket"):
			match hand_ray.collider:
				hand_ray.collider when hand_ray.collider is Item:
					var item: Item = hand_ray.collider
					inventory.add_to_inventory(item)
		return

	if held_prop:
		if event.is_action_pressed("interact"):
			held_prop.freeze = false
			held_prop = null


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
	var input_dir: Vector2 = Input.get_vector("left", "right", "forwards", "backwards")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
		t_bob = 0

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = (
		_headbob(t_bob)
		+ (
			Vector3(0, 1, 0)
			if (can_stand and not Input.is_action_pressed("crouch"))
			else Vector3(0, 0.2, 0)
		)
	)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"):
		top_half_1.disabled = true
		top_half_2.disabled = true
		speed = CROUCH_SPEED


func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 1.5) * BOB_AMP
	return pos


func _process(_delta: float) -> void:
	if can_stand and not Input.is_action_pressed("crouch"):
		top_half_1.disabled = false
		top_half_2.disabled = false
		speed = WALK_SPEED

	# Handle what the player is looking at
	hand_ray = _handle_raycast()

	if held_prop:
		held_prop.position = hand_ray.hold_pos
		if not held_prop_y_rotation:
			held_prop.rotation.y = rotation.y
			# held_prop.rotation.x = camera.rotation.x

	if not PlayerUi.inventory_opened:
		PlayerUi.item_tooltip.draw_world_tooltip(hand_ray.collider, held_prop != null)


func drop_in_front(prop: Prop) -> void:
	get_parent().add_child(prop)
	prop.global_position = hand_ray.hold_pos


func _scroll_to_rotate(modifier: float) -> void:
	if held_prop_y_rotation == null:
		held_prop_y_rotation = rotation.y
	else:
		held_prop_y_rotation = held_prop_y_rotation + modifier
		held_prop.rotation.y = held_prop_y_rotation


func _handle_prop_pickup(prop: Prop) -> void:
	held_prop = prop
	held_prop.freeze = true
	held_prop_y_rotation = null


func _on_top_half_area_body_entered(body: Node3D) -> void:
	if not body is PlayerController:
		can_stand = false


func _on_top_half_area_body_exited(body: Node3D) -> void:
	if not body is PlayerController:
		can_stand = true


func _handle_raycast() -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var mousepos: Vector2 = get_viewport().get_mouse_position()
	if PlayerUi.inventory_opened:
		mousepos = get_viewport().get_visible_rect().size / 2
	var origin: Vector3 = camera.project_ray_origin(mousepos)
	var end: Vector3 = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE
	var hold_pos: Vector3 = origin + camera.project_ray_normal(mousepos) * REACH_DISTANCE / 2.5
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 2)
	var result: Dictionary = space_state.intersect_ray(query)
	var collider: Variant = result.get("collider")

	return {"collider": collider, "hold_pos": hold_pos}
