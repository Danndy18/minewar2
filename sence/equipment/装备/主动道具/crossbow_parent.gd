extends "res://sence/equipment/装备/主动道具/active_item_parent.gd"

enum State { READY, AIMING, FIREING, RELOAD_IDLE, RELOAD_CHARGING }

@export var bolt_speed: float = 480.0
@export var damage: int = 5
@export var ammo: int = 1
@export var reload_frames: int = 120

var _state: int = State.READY
var _reload_progress: int = 0
var _prev_held: bool = false
var _fire_tick: int = 0
var _aim_frames: int = 0
var _aim_flash_fade: int = 0

const CROSSBOW_EFFECT = preload("res://sence/equipment/装备/武器/武器效果/投射物攻击.tscn")


func apply_to(pieces_parent: Node) -> void:
	_state = State.READY
	_reload_progress = 0
	var ws: AnimatedSprite2D = get_node_or_null(sprite_node)
	if ws:
		ws.visible = true


func sync(parent: Node) -> void:
	super.sync(parent)

	match _state:
		State.READY:
			parent._override_upper_anim = ""
			if parent.active_item_held and not _prev_held:
				_aim_frames = 0
				_state = State.AIMING
				_aim(parent)

		State.AIMING:
			parent._block_attack = true
			parent.effect_pool.move_speed *= 0.5
			if parent.active_item_held:
				_aim_frames += 1
				_aim(parent)
			else:
				_fire(parent)

		State.FIREING:
			parent._block_attack = true
			parent.effect_pool.move_speed *= 0.8
			_fire_tick += 1
			var anim_frame = _fire_tick_to_frame(_fire_tick)
			if anim_frame >= 3:
				_on_fire_done(parent)
			else:
				parent._override_upper_anim = "上半身-单手抬手-挥舞"
				parent._override_upper_frame = anim_frame
				var spr: AnimatedSprite2D = get_node_or_null(sprite_node)
				if spr:
					spr.animation = "上半身-单手抬手-挥舞"
					spr.frame = anim_frame
					spr.z_index = parent.z_index

		State.RELOAD_IDLE:
			if parent.active_item_held and not _prev_held:
				_state = State.RELOAD_CHARGING
				_reload_progress = 0

		State.RELOAD_CHARGING:
			parent._block_attack = true
			parent.effect_pool.move_speed *= 0.25
			if parent.active_item_held:
				_reload_progress += 1
				_play_reload_anim(parent)
				if _reload_progress >= reload_frames:
					ammo = 1
					_reload_progress = 0
					_state = State.READY
					parent._override_upper_anim = ""
			else:
				if _reload_progress > 0:
					_reload_progress = 0
				parent._override_upper_anim = ""
				_state = State.RELOAD_IDLE

	_prev_held = parent.active_item_held


func _aim(parent: Node) -> void:
	parent._override_upper_anim = "上半身-单手抬手"
	parent._override_upper_frame = 0
	var spr: AnimatedSprite2D = get_node_or_null(sprite_node)
	if spr:
		spr.animation = "上半身-单手抬手"
		spr.frame = 0
		spr.z_index = parent.z_index
		if _aim_frames == 25:
			_aim_flash_fade = 8
			spr.self_modulate = Color(1.5, 1.5, 1.5, 1)
		if _aim_flash_fade > 0:
			_aim_flash_fade -= 1
			var t = _aim_flash_fade / 8.0
			var c = 1.0 + t * 0.5
			spr.self_modulate = Color(c, c, c, 1)
		elif _aim_frames < 25:
			spr.self_modulate = Color(1, 1, 1, 1)


func _fire(parent: Node) -> void:
	ammo -= 1
	_fire_tick = 0
	_state = State.FIREING
	var spr: AnimatedSprite2D = get_node_or_null(sprite_node)
	if spr:
		spr.self_modulate = Color(1, 1, 1, 1)

	var aim_acc = min(0.5 + _aim_frames / 25.0 * 0.5, 1.0)
	var proj = CROSSBOW_EFFECT.instantiate()
	proj.setup(parent, {
		weapon_damage = damage,
		weapon_type = "弩",
		counter_shield = false,
		hit_rate = aim_acc,
		hit_decay_start = 20,
		hit_decay_end = 60,
		gravity_step = 0.03,
	})
	parent.add_child(proj)


func _fire_tick_to_frame(tick: int) -> int:
	if tick <= 3:
		return 0
	elif tick <= 6:
		return 1
	elif tick <= 16:
		return 2
	return 3


func _on_fire_done(parent: Node) -> void:
	if ammo <= 0:
		_state = State.RELOAD_IDLE
		parent._override_upper_anim = ""
		var spr: AnimatedSprite2D = get_node_or_null(sprite_node)
		if spr:
			spr.visible = false
	else:
		_state = State.READY
		parent._override_upper_anim = ""


func _play_reload_anim(parent: Node) -> void:
	var total_frames = 5
	var frame = clampi(int(_reload_progress * total_frames / reload_frames), 0, total_frames - 1)
	parent._override_upper_anim = "上半身-蓄力-前摇"
	parent._override_upper_frame = frame
	var spr: AnimatedSprite2D = get_node_or_null(sprite_node)
	if spr:
		spr.visible = true
		spr.animation = "上半身-蓄力-前摇"
		spr.frame = frame
		spr.z_index = parent.z_index


func get_equipment_sprites() -> Array:
	return [get_node_or_null(sprite_node)]
