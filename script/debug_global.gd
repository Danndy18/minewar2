extends Node

var _debug_on: bool = false


func _ready():
	process_mode = PROCESS_MODE_ALWAYS


func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_F7 and event.pressed:
		_debug_on = not _debug_on
		get_tree().debug_collisions_hint = _debug_on
		_force_redraw_all()
		get_viewport().set_input_as_handled()


func _force_redraw_all():
	var tree = get_tree()
	var stack: Array[Node] = [tree.root]
	while not stack.is_empty():
		var n = stack.pop_back()
		if not is_instance_valid(n):
			continue
		if n is CollisionShape2D or n is CollisionPolygon2D:
			n.queue_redraw()
		stack.append_array(n.get_children())
