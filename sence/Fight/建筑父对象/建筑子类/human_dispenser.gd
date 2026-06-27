extends "res://sence/Fight/建筑父对象/building_parent.gd"

# 人力发射器 — 炮塔类建筑
# 常态化为"待机_关"（闭合），被交互后变为"待机_开"（开启）
# 每次打开时发射一根弩箭


var active: bool = false
var _prev_active: bool = false

const CROSSBOW_BOLT = preload("res://sence/equipment/装备/武器/武器效果/投射物攻击.tscn")

@onready var _spr: AnimatedSprite2D = $Sprite


func _ready():
	super._ready()
	if _spr:
		_spr.position.y += 1


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _phase == "normal" and active and not _prev_active:
		_fire()
	_prev_active = active


func _on_entry_finished():
	_phase = "normal"
	if _spr:
		_spr.animation = "待机_关"
		_spr.frame = 0
		_spr.play()
	_on_normal_start()


func can_interact(unit: Node) -> bool:
	return true


func interact(unit: Node) -> void:
	active = not active
	if _spr:
		_spr.animation = "待机_开" if active else "待机_关"
		_spr.frame = 0
		_spr.play()


func _fire():
	var proj = CROSSBOW_BOLT.instantiate()
	proj.setup(self, {
		weapon_damage = 5,
		weapon_type = "弩",
		counter_shield = false,
		hit_rate = 0.5,
		hit_decay_start = 20,
		hit_decay_end = 60,
		gravity_step = 0.03,
	})
	add_child(proj)
	var offset_dir = 1 if camp == 0 else -1
	proj.position = Vector2(-8 * offset_dir, -2)
