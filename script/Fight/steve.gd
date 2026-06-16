extends "res://script/soldier.gd"

func _init() -> void:
	camp = "friend"
	direction = Vector2.RIGHT
	health = 3
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
pass
 
