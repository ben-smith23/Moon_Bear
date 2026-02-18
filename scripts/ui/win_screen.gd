extends Control

@onready var message_label: Label = %MessageLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_win_time(time_seconds: float) -> void:
	message_label.text = "Mission Accomplished!\nTime: %.1f seconds" % time_seconds

func set_loss() -> void:
	message_label.text = "Mission Failed!\nYou were caught by the Moon Bear."
	message_label.modulate = Color(1.0, 0.3, 0.3) # Red text

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
