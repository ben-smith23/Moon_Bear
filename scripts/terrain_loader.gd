extends Node3D

## Terrain loader that sets up the moon terrain with collision and boundaries

@export var terrain_scene_path: String = "res://assets/models/moon_terrain.glb"
@export var map_size: float = 200# Approximate size of terrain

func _ready() -> void:
	# Load the terrain GLB
	var terrain_resource = load(terrain_scene_path)
	if terrain_resource:
		var terrain_instance = terrain_resource.instantiate()
		add_child(terrain_instance)
		
		# Wait one frame for the scene tree to be ready
		await get_tree().process_frame
		
		# Find all MeshInstance3D nodes and create collision
		_create_collision_for_meshes(terrain_instance)
		
		# Add invisible boundary walls
		_create_boundaries()
		
		print("Moon terrain loaded successfully!")
	else:
		push_error("Failed to load terrain from: " + terrain_scene_path)

func _create_collision_for_meshes(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		mesh_instance.create_trimesh_collision()
		print("Created collision for mesh: ", mesh_instance.name)
	
	for child in node.get_children():
		_create_collision_for_meshes(child)

func _create_boundaries() -> void:
	# Create invisible walls around the map edges
	var wall_height := 50.0
	var wall_thickness := 2.0
	var half_size := map_size / 2.0
	
	# Wall positions: [position, size]
	var walls := [
		[Vector3(half_size, wall_height/2, 0), Vector3(wall_thickness, wall_height, map_size)],   # East
		[Vector3(-half_size, wall_height/2, 0), Vector3(wall_thickness, wall_height, map_size)],  # West
		[Vector3(0, wall_height/2, half_size), Vector3(map_size, wall_height, wall_thickness)],   # North
		[Vector3(0, wall_height/2, -half_size), Vector3(map_size, wall_height, wall_thickness)],  # South
	]
	
	for i in walls.size():
		var wall_body := StaticBody3D.new()
		wall_body.name = "BoundaryWall_" + str(i)
		wall_body.position = walls[i][0]
		
		var collision := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = walls[i][1]
		collision.shape = box
		wall_body.add_child(collision)
		
		add_child(wall_body)
	
	print("Created boundary walls at size: ", map_size)
