extends "res://script/soldier.gd"

func _init() -> void:
	camp = "enemy"
	direction = Vector2.LEFT
	health = 2
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
pass
