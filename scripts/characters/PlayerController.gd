extends CharacterBody3D

# Dash
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

# Camera
@onready var model = $CharacterModel
@onready var camera_target = $CameraController/CameraTarget


func _physics_process(delta: float) -> void:
	update_dash_state(delta)
	handle_movement(delta)
	apply_gravity(delta)
	move_and_slide()


# --------------------------------------------------------------------------- #
# Dash Logic
# --------------------------------------------------------------------------- #

func start_dash() -> void:
	is_dashing = true
	dash_timer = Constants.DASH_DURATION

func update_dash_state(delta: float) -> void:
	if dash_cooldown_timer > 0.0: 
		dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)

	if is_dashing:
		if dash_timer > 0.0:
			dash_timer = max(dash_timer - delta, 0.0)

		if dash_timer == 0.0:
			is_dashing = false
			dash_cooldown_timer = Constants.DASH_COOLDOWN

# --------------------------------------------------------------------------- #
# Direction, Model Rotation, and Gravity
# --------------------------------------------------------------------------- #

func handle_movement(delta: float) -> void:
	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = Constants.JUMP_VELOCITY

	# handle dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer == 0.0:
		start_dash()

	# get input, set speed
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_speed = Constants.DASH_SPEED if is_dashing else Constants.SPEED

	if input_dir.length() > 0:
		# process input
		var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		var rotation_basis = Basis(Vector3.UP, camera_target.rotation.y) * direction
		direction = rotation_basis.normalized()

		# apply to velocity
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

		# rotate model to input direction
		var target_rotation_y = atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation_y, delta * 15)
	else:
		velocity.x = move_toward(velocity.x, 0, Constants.SPEED)
		velocity.z = move_toward(velocity.z, 0, Constants.SPEED)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
