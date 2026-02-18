extends CharacterBody3D

# Moon gravity (1.62 m/s² vs Earth's 9.8)
const GRAVITY: float = 1.62
const JUMP_VELOCITY: float = 3.0
const SPEED: float = 3.0
const FAST_SPEED: float = 6.0

# Stamina Settings
const MAX_STAMINA: float = 100.0
const SPRINT_COST: float = 30.0  # Cost per second
const STAMINA_REGEN: float = 15.0 # Regen per second

var stamina: float = MAX_STAMINA
var is_exhausted: bool = false

# Signal for aliens to detect sprinting
signal player_sprinted(position: Vector3)
var sprint_signal_cooldown: float = 0.0

# Visual effects
var dust_scene = preload("res://scenes/effects/dust_particles.tscn")
var dust_timer: float = 0.0
var was_in_air: bool = false
var fall_velocity: float = 0.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var model: Node3D = $Model

var mouse_sensitivity: float = 0.005
var camera_rotation: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	stamina_bar.max_value = MAX_STAMINA
	stamina_bar.value = stamina

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_rotation.x -= event.relative.x * mouse_sensitivity
		camera_rotation.y -= event.relative.y * mouse_sensitivity
		camera_rotation.y = clamp(camera_rotation.y, -0.3, 1.2)
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	camera_pivot.rotation.y = camera_rotation.x + deg_to_rad(15)
	camera_pivot.rotation.x = camera_rotation.y
	
	# Rotate model to face camera direction (horizontal only)
	if model:
		model.rotation.y = camera_rotation.x
	
	# Track air state for landing effects
	if not is_on_floor():
		was_in_air = true
		fall_velocity = velocity.y
		velocity.y -= GRAVITY * delta
	else:
		# Just landed
		if was_in_air:
			on_land(fall_velocity)
			was_in_air = false
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var is_trying_to_sprint := Input.is_key_pressed(KEY_SHIFT) and input_dir.length() > 0
	
	# Stamina Logic
	var can_sprint := is_trying_to_sprint and stamina > 0 and not is_exhausted
	
	if can_sprint:
		stamina -= SPRINT_COST * delta
		# Emit sprint signal for aliens to hear (with cooldown)
		sprint_signal_cooldown -= delta
		if sprint_signal_cooldown <= 0:
			player_sprinted.emit(global_position)
			sprint_signal_cooldown = 0.5  # Emit every 0.5s while sprinting
	else:
		stamina += STAMINA_REGEN * delta
	
	stamina = clamp(stamina, 0, MAX_STAMINA)
	
	# Exhaustion Logic
	if stamina <= 0:
		is_exhausted = true
	elif stamina >= MAX_STAMINA:
		is_exhausted = false
		
	# Update UI
	stamina_bar.value = stamina
	
	# Color Logic
	if stamina >= MAX_STAMINA:
		# Light Green when full
		stamina_bar.modulate = Color(0.4, 1.0, 0.4)
	elif is_exhausted:
		# Red when exhausted
		stamina_bar.modulate = Color(1.0, 0.3, 0.3)
	else:
		# White/Yellowish when recovering or using but not exhausted
		stamina_bar.modulate = Color(1.0, 1.0, 1.0)
	
	# Movement Logic
	var cam_basis := camera_pivot.global_transform.basis
	var direction := Vector3.ZERO
	direction += cam_basis.x * input_dir.x
	direction += cam_basis.z * input_dir.y
	direction.y = 0
	
	var target_speed := FAST_SPEED if can_sprint else SPEED
	
	if direction.length() > 0:
		direction = direction.normalized()
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed * delta * 5)
		velocity.z = move_toward(velocity.z, 0, target_speed * delta * 5)
	
	move_and_slide()
	
	# Spawn dust when moving on ground
	if is_on_floor() and velocity.length() > 0.5:
		dust_timer -= delta
		if dust_timer <= 0:
			spawn_dust()
			dust_timer = 0.3 if can_sprint else 0.5
	
	# Debug coordinate display removed for release

func spawn_dust() -> void:
	var dust = dust_scene.instantiate()
	get_tree().root.add_child(dust)
	dust.global_position = global_position
	dust.emitting = true
	# Auto-cleanup after particles finish
	get_tree().create_timer(2.0).timeout.connect(func(): dust.queue_free())

func on_land(impact_velocity: float) -> void:
	# Spawn landing dust
	spawn_dust()
	
	# Trigger screen shake if falling hard
	if abs(impact_velocity) > 1.0:
		var visual_fx = get_tree().get_first_node_in_group("visual_effects")
		if visual_fx and visual_fx.has_method("trigger_land_shake"):
			visual_fx.trigger_land_shake(impact_velocity)
