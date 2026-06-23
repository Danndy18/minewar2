extends Node

func _ready():
	process_mode = PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_F7 and event.pressed:
		get_tree().debug_collisions_hint = not get_tree().debug_collisions_hint
		get_viewport().set_input_as_handled()
