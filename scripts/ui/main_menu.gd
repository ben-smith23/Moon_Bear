extends Control

@onready var instructions_panel: Control = $InstructionsPanel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if instructions_panel:
		instructions_panel.hide()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_instructions_button_pressed() -> void:
	if instructions_panel:
		instructions_panel.show()

func _on_back_button_pressed() -> void:
	if instructions_panel:
		instructions_panel.hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
