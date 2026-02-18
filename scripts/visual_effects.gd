extends CanvasLayer

# Visual effects manager for screen shake only (removed danger indicators for horror atmosphere)

var player: Node3D = null
var screen_shake_amount: float = 0.0
var camera: Camera3D = null
var original_camera_pos: Vector3 = Vector3.ZERO

const SHAKE_DECAY: float = 5.0

func _ready() -> void:
	add_to_group("visual_effects")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D")
		if camera:
			original_camera_pos = camera.position

func _process(delta: float) -> void:
	update_screen_shake(delta)

func update_screen_shake(delta: float) -> void:
	if not camera:
		return
	
	# Decay shake
	screen_shake_amount = max(0, screen_shake_amount - SHAKE_DECAY * delta)
	
	if screen_shake_amount > 0:
		var shake_offset = Vector3(
			randf_range(-1, 1) * screen_shake_amount,
			randf_range(-1, 1) * screen_shake_amount,
			0
		) * 0.05
		camera.position = original_camera_pos + shake_offset
	else:
		camera.position = original_camera_pos

# Call this from player when landing
func trigger_land_shake(velocity_y: float) -> void:
	var impact = abs(velocity_y) / 5.0
	screen_shake_amount = clamp(impact, 0.0, 1.0)

# Call this when alien attacks
func trigger_attack_shake() -> void:
	screen_shake_amount = 2.0
