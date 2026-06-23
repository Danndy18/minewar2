extends Node2D

const PARTICLE_ANIMS = ["poof_1", "poof_2", "poof_3", "poof_4", "poof_5"]
const FADE_DELAY = 1.0
const FADE_DURATION = 0.5

var _life: float = 0.0


func _ready():
	randomize()
	var puff = preload("res://sence/equipment/特效/particle_puff.gd")
	for anim in PARTICLE_ANIMS:
		var spr = AnimatedSprite2D.new()
		spr.set_script(puff)
		spr.setup(anim)
		add_child(spr)


func _process(delta: float) -> void:
	_life += delta
	if _life > FADE_DELAY:
		var a = 1.0 - (_life - FADE_DELAY) / FADE_DURATION
		modulate.a = maxf(a, 0.0)
		if _life > FADE_DELAY + FADE_DURATION:
			queue_free()
