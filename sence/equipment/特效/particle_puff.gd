extends AnimatedSprite2D

const POOF_FRAMES = preload("res://rescourse/particle/poof.tres")

var _drift_x: float = 0.0
var _float_y: float = -0.25


func setup(anim_name: String):
	sprite_frames = POOF_FRAMES
	animation = anim_name
	var s = randf_range(2.0, 4.0)
	scale = Vector2(s, s)
	position = Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
	position.y += randf_range(0.0, 4.0)
	play()
	_drift_x = randf_range(-1.0, 1.0)
	_float_y = randf_range(-0.45, 0.1)


func _process(delta: float) -> void:
	position.x += _drift_x
	position.y += _float_y
	_drift_x = move_toward(_drift_x, 0.0, 0.02)
