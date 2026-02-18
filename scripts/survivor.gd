extends CharacterBody3D

const GRAVITY: float = 1.62
const SPEED: float = 2.5
const FOLLOW_DISTANCE: float = 2.5
const TRIGGER_DISTANCE: float = 5.0

enum State { IDLE, FOLLOWING }
var state = State.IDLE

var player: Node3D = null
@onready var model: Node3D = $Model

func _ready() -> void:
	# Wait a frame to ensure player is ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		add_collision_exception_with(player)

func _physics_process(delta: float) -> void:
	# Always try to find player
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if player:
		var dist = global_position.distance_to(player.global_position)
		
		if state == State.IDLE:
			if dist < TRIGGER_DISTANCE:
				state = State.FOLLOWING
				# Jump for joy!
				if is_on_floor():
					velocity.y = 2.0
		
		elif state == State.FOLLOWING:
			# Always face the player (rotate model only, not the body)
			face_player()
			
			if dist > FOLLOW_DISTANCE:
				# Move towards player
				var direction = (player.global_position - global_position).normalized()
				direction.y = 0
				
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				# Stop if close enough
				velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)
				velocity.z = move_toward(velocity.z, 0, SPEED * delta * 5)

	move_and_slide()

func face_player() -> void:
	if not player or not model:
		return
	
	# Calculate angle to player
	var dir_to_player = player.global_position - global_position
	dir_to_player.y = 0
	
	if dir_to_player.length() > 0.1:
		var angle = atan2(dir_to_player.x, dir_to_player.z)
		model.rotation.y = angle + PI
