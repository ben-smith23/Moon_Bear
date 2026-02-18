extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var win_area: Area3D = %WinArea
@onready var ui_layer: CanvasLayer = CanvasLayer.new()

var game_active: bool = true
var time_elapsed: float = 0.0
var win_screen_scene = preload("res://scenes/ui/win_screen.tscn")
var survivor_scene = preload("res://scenes/player/survivor.tscn")
var alien_scene = preload("res://scenes/enemy/alien.tscn")
var visual_effects_scene = preload("res://scenes/ui/visual_effects.tscn")
var survivor: Node3D = null
var visual_effects: CanvasLayer = null

func _ready() -> void:
	add_child(ui_layer)
	
	# Add visual effects layer
	visual_effects = visual_effects_scene.instantiate()
	add_child(visual_effects)
	
	randomize_spawn()
	spawn_survivor()
	for i in range(3):
		spawn_alien()
	
	# Connect win area signal
	win_area.body_entered.connect(_on_body_entered_win_area)

func _process(delta: float) -> void:
	if game_active:
		time_elapsed += delta

func randomize_spawn() -> void:
	var x = randf_range(-95, 95)
	var z = randf_range(-95, 95)
	player.global_position = Vector3(x, 10, z)
	player.velocity = Vector3.ZERO

func spawn_survivor() -> void:
	survivor = survivor_scene.instantiate()
	add_child(survivor)
	
	var valid_pos = false
	var x = 0.0
	var z = 0.0
	
	while not valid_pos:
		x = randf_range(-95, 95)
		z = randf_range(-95, 95)
		var pos = Vector3(x, 0, z)
		var dist_to_lem = pos.distance_to(Vector3(-10, 0, 11))
		
		# Ensure at least 50m away from LEM
		if dist_to_lem > 50.0:
			valid_pos = true
			
	survivor.global_position = Vector3(x, 10, z)

func spawn_alien() -> void:
	var alien = alien_scene.instantiate()
	add_child(alien)
	
	# Debug labels disabled for release
	alien.debug_mode = false
	
	var valid_pos = false
	var x = 0.0
	var z = 0.0
	
	# Try to spawn far from player
	while not valid_pos:
		x = randf_range(-95, 95)
		z = randf_range(-95, 95)
		var pos = Vector3(x, 10, z)
		var dist_to_player = pos.distance_to(player.global_position)
		
		# Ensure at least 60m away
		if dist_to_player > 60.0:
			valid_pos = true
			
	alien.global_position = Vector3(x, 10, z)

func _on_body_entered_win_area(body: Node3D) -> void:
	if body == player and game_active:
		if survivor:
			var dist = survivor.global_position.distance_to(win_area.global_position)
			if dist < 10.0:
				game_over_win()

func game_over_win() -> void:
	game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var win_screen = win_screen_scene.instantiate()
	ui_layer.add_child(win_screen)
	
	if win_screen.has_method("set_win_time"):
		win_screen.set_win_time(time_elapsed)

func game_over_lose() -> void:
	if not game_active: return
	game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var win_screen = win_screen_scene.instantiate()
	ui_layer.add_child(win_screen)
	
	if win_screen.has_method("set_loss"):
		win_screen.set_loss()
