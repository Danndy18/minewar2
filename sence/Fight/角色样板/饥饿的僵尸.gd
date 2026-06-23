extends "res://sence/Fight/角色样板/僵尸样板.gd"

var _low_hp_done: bool = false


func _ready() -> void:
	super()
	if not _low_hp_done:
		health_current = health_limit * 0.25
		_low_hp_done = true
