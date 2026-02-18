extends Node3D

@export var orbit_distance_x: float = 300.0  # How far away it is on the horizon
@export var orbit_height_y: float = 30   # Slightly higher to ensure terrain clearance
@export var orbit_speed: float = 0.05     # Very slow, cinematic movement

var angle: float = PI * 2  # Start behind the player (between horizon and zenith)
var _has_gateway: bool = true

func _ready() -> void:
	# On web builds, the Gateway model is excluded to reduce download size.
	# If the child node failed to load, just disable orbit processing.
	if get_child_count() == 0:
		_has_gateway = false
		set_process(false)

func _process(delta: float) -> void:
	if not _has_gateway:
		return
	
	angle += orbit_speed * delta
	
	# Elliptical orbit logic centered at (0,0,0)
	var x = cos(angle) * orbit_distance_x
	var y = sin(angle) * orbit_height_y
	var z = 0.0  # Fly strictly along the center line
	
	position = Vector3(x, y, z)
	
	# Face direction of travel
	var dx = -sin(angle) * orbit_distance_x
	var dy = cos(angle) * orbit_height_y
	
	var tangent = Vector3(dx, dy, 0).normalized()
	
	if tangent.length_squared() > 0.001:
		look_at(position + tangent, Vector3.UP)
		rotate_object_local(Vector3.UP, PI)
