extends CharacterBody3D

@onready var head: Node3D = $Head
@export var mouse_sensitivity: float = 0.003

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Movement constants
const CROUCH_SPEED: float = 2
const WALK_SPEED: float = 4.5
const SPRINT_SPEED: float = 7.0
const JUMP_VELOCITY: float = 5.0
const JUMP_MULTIPLIER_ON_RELEASE: float = 0.75
const STAND_HEIGHT: float = 1.0
const CROUCH_HEIGHT: float = 0.5

# Changing variables
var current_speed: float = 0.0

func handle_crouch() -> void:
	if Input.is_action_pressed("Crouch"):
		head.position.y = CROUCH_HEIGHT
	else:
		head.position.y = STAND_HEIGHT

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	handle_crouch()

	# Handle jumping
	if Input.is_action_just_pressed("Jump") and not Input.is_action_pressed("Crouch") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle variable jump height
	if Input.is_action_just_released("Jump") and velocity.y > 0.0:
		velocity.y *= JUMP_MULTIPLIER_ON_RELEASE

	# Handle movement speed
	if Input.is_action_pressed("Crouch"):
		current_speed = CROUCH_SPEED
	elif Input.is_action_pressed("Sprint"):
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED

	# Get movement input
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle movement and deceleration
	if is_on_floor() and direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	elif is_on_floor():
		handle_lateral_inertia(direction, delta, 5.0)
	else:
		handle_lateral_inertia(direction, delta, 1.0)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Head.rotate_x(-event.relative.y * mouse_sensitivity)

	$Head.rotation.x = clamp(
	$Head.rotation.x,
	deg_to_rad(-89.0),
	deg_to_rad(89.0)
		)

func handle_lateral_inertia(direction: Vector3, delta: float, amount: float) -> void:
	velocity.x = lerp(velocity.x, direction.x * current_speed, delta * amount)
	velocity.z = lerp(velocity.z, direction.z * current_speed, delta * amount)
