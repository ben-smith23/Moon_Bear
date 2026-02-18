extends CharacterBody3D

# === CORE SETTINGS ===
const SPEED: float = 4.5
const WANDER_SPEED: float = 2.0
const GRAVITY: float = 1.62
const ATTACK_RANGE: float = 1.5
const DETECTION_RADIUS: float = 50.0  # Will chase if within this AND has line of sight
const ALWAYS_DETECT_RADIUS: float = 15.0  # Will ALWAYS detect player within this range
const LOSE_INTEREST_TIME: float = 5.0

# === STATE ===
enum State { WANDER, CHASE }
var state = State.WANDER
var wander_target: Vector3 = Vector3.ZERO
var time_since_saw_player: float = 0.0
var player: CharacterBody3D = null

# === DEBUG ===
@export var debug_mode: bool = false
var debug_label: Label3D = null

@onready var game_manager = get_parent()
@onready var animation_player: AnimationPlayer = $Model.get_node_or_null("AnimationPlayer")
@onready var model: Node3D = $Model

func _ready() -> void:
	# Find animation player in model children if not at expected path
	if not animation_player:
		for child in $Model.get_children():
			if child is AnimationPlayer:
				animation_player = child
				break
	
	# Pick first wander target
	pick_wander_target()
	
	# Setup debug
	if debug_mode:
		debug_label = Label3D.new()
		debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		debug_label.font_size = 48
		debug_label.position = Vector3(0, 2.5, 0)
		debug_label.modulate = Color.YELLOW
		add_child(debug_label)

func _physics_process(delta: float) -> void:
	# === ALWAYS FIND PLAYER ===
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	
	# === GRAVITY ===
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# === DETECTION (runs every frame) ===
	if player:
		var dist = global_position.distance_to(player.global_position)
		
		# Close range = ALWAYS detect
		if dist < ALWAYS_DETECT_RADIUS:
			if state != State.CHASE:
				state = State.CHASE
				time_since_saw_player = 0.0
		# Medium range = need line of sight
		elif dist < DETECTION_RADIUS:
			if can_see_player():
				if state != State.CHASE:
					state = State.CHASE
				time_since_saw_player = 0.0
	
	# === STATE BEHAVIOR ===
	match state:
		State.WANDER:
			do_wander(delta)
		State.CHASE:
			do_chase(delta)
	
	move_and_slide()
	
	# === DEBUG ===
	if debug_mode and debug_label:
		var dist_text = ""
		if player:
			dist_text = " (%.0fm)" % global_position.distance_to(player.global_position)
		debug_label.text = State.keys()[state] + dist_text

func can_see_player() -> bool:
	if not player:
		return false
	
	var space = get_world_3d().direct_space_state
	var from = global_position + Vector3(0, 1.0, 0)
	var to = player.global_position + Vector3(0, 0.3, 0)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]  # Don't hit ourselves
	
	var result = space.intersect_ray(query)
	
	# If we hit the player, we can see them
	# If we hit nothing or something else, we can't
	if result.is_empty():
		return true  # Nothing in the way
	return result.collider == player

func do_wander(delta: float) -> void:
	var dir = (wander_target - global_position)
	dir.y = 0
	var dist = dir.length()
	
	if dist < 2.0:
		pick_wander_target()
		return
	
	dir = dir.normalized()
	velocity.x = dir.x * WANDER_SPEED
	velocity.z = dir.z * WANDER_SPEED
	
	face_movement_direction()
	play_anim("Walk")

func do_chase(delta: float) -> void:
	if not player:
		state = State.WANDER
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	# Attack if close
	if dist < ATTACK_RANGE:
		attack_player()
		return
	
	# Check if we can still see player
	if can_see_player() or dist < ALWAYS_DETECT_RADIUS:
		time_since_saw_player = 0.0
	else:
		time_since_saw_player += delta
		if time_since_saw_player > LOSE_INTEREST_TIME:
			state = State.WANDER
			pick_wander_target()
			return
	
	# Move toward player
	var dir = (player.global_position - global_position)
	dir.y = 0
	dir = dir.normalized()
	
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	
	face_movement_direction()
	play_anim("Run")

func pick_wander_target() -> void:
	wander_target = Vector3(
		randf_range(-95, 95),
		global_position.y,
		randf_range(-95, 95)
	)

func attack_player() -> void:
	var visual_fx = get_tree().get_first_node_in_group("visual_effects")
	if visual_fx and visual_fx.has_method("trigger_attack_shake"):
		visual_fx.trigger_attack_shake()
	
	if game_manager.has_method("game_over_lose"):
		game_manager.game_over_lose()

func play_anim(anim_name: String) -> void:
	if not animation_player:
		return
	if animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)
	elif animation_player.has_animation(anim_name.to_lower()):
		if animation_player.current_animation != anim_name.to_lower():
			animation_player.play(anim_name.to_lower())

func face_movement_direction() -> void:
	if not model:
		return
	
	# Get horizontal velocity
	var move_dir = Vector3(velocity.x, 0, velocity.z)
	if move_dir.length() > 0.1:
		var angle = atan2(move_dir.x, move_dir.z)
		model.rotation.y = angle
