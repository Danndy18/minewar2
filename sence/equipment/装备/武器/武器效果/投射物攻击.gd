extends Area2D

const ARROW_IN = preload("res://rescourse/object/character/humanlike/equipment/weapons/bow/arrow_in.png")

var _parent = null
var _damage: int = 0
var _weapon_type: String = ""
var _speed: float = 360.0
var _stuck: bool = false
var _done: bool = false
var _detached: bool = false
var _grace_frames: int = 1
var _gravity: float = -0.2
var _gravity_step: float = 0.005
var _rot_speed: float = 0.2
var _fade_alpha: float = 1.0
var _fading: bool = false
var _dir: int = 1
var _shield_bounce: bool = false
var _counter_shield: bool = false

var _flight_frame: int = 0
var _base_hit_rate: float = 1.0
var _decay_start: int = 40
var _decay_end: int = 80

# 弹射物名片：告诉目标我是弹射物
var is_projectile: bool = true


func setup(parent: Node, cfg: Dictionary):
	_parent = parent
	_damage = cfg.get("weapon_damage", 0)
	_weapon_type = cfg.get("weapon_type", "")
	_counter_shield = cfg.get("counter_shield", false)
	_dir = 1 if parent.camp == 0 else -1
	var _angle_deg = randf_range(-10, -2)
	rotation = deg_to_rad(_angle_deg)
	_gravity = -0.8 + (_angle_deg + 10) / 8.0 * 0.4
	_gravity_step = 0.015
	_rot_speed = (0.3 - (_angle_deg + 10) / 8.0 * 0.1) * _dir
	area_entered.connect(_on_area_entered)
	collision_mask = 4
	z_as_relative = false
	z_index = parent.z_index + 1

	_base_hit_rate = cfg.get("hit_rate", 1.0)
	_decay_start = cfg.get("hit_decay_start", 40)
	_decay_end = cfg.get("hit_decay_end", 80)
	_gravity_step = cfg.get("gravity_step", _gravity_step)


func _physics_process(delta: float) -> void:
	if _done:
		return
	if not _detached:
		_detached = true
		reparent(get_tree().root)
	if _grace_frames > 0:
		_grace_frames -= 1
	if _stuck:
		return
	if _shield_bounce:
		_gravity += 1.5
	position.x += _speed * _dir * delta
	position.y += _gravity
	_gravity += _gravity_step
	rotation += deg_to_rad(_rot_speed)
	_flight_frame += 1
	if get_tree().debug_collisions_hint:
		print("箭矢 frame=", _flight_frame, " hit_rate=", _calc_hit_rate())
	queue_redraw()


func _draw():
	if get_tree().debug_collisions_hint:
		var main = get_node_or_null("CollisionShape2D")
		if main and main.shape:
			var r = main.shape.extents
			var pos = main.position
			var w = maxf(r.x * 2.0, 3.0)
			var h = maxf(r.y * 2.0, 3.0)
			draw_rect(Rect2(pos.x - w / 2.0, pos.y - h / 2.0, w, h), Color.YELLOW, false, 1.0)


func _die():
	if get_tree().debug_collisions_hint:
		print("箭矢死亡")
	_swap_to_hit()
	_start_fade()


func _calc_hit_rate() -> float:
	if _flight_frame <= _decay_start:
		return _base_hit_rate
	if _flight_frame >= _decay_end:
		return 0.0
	var t = float(_flight_frame - _decay_start) / float(_decay_end - _decay_start)
	return _base_hit_rate * (1.0 - t)


func _swap_to_hit():
	var sprite = $Sprite2D
	if sprite:
		sprite.texture = ARROW_IN


func _start_fade():
	_done = true
	_fading = true


func _process(delta: float) -> void:
	if not _fading:
		return
	_fade_alpha -= 0.01
	if _fade_alpha <= 0:
		queue_free()
		return
	modulate = Color(1, 1, 1, _fade_alpha)


func _on_area_entered(area: Area2D) -> void:
	if _stuck or _done or _grace_frames > 0:
		return
	if not is_instance_valid(area) or not is_instance_valid(_parent):
		return
	var c = area.get("camp")
	if c == null:
		_die()
		return
	if c != _parent.camp:
		if randf() > _calc_hit_rate():
			if get_tree().debug_collisions_hint:
				print("箭矢未命中, frame=", _flight_frame)
			return
		var shield_node = area if area.get("shield_health") != null else (area.get("parent_node") if area.get("parent_node") and area.get("parent_node").get("shield_health") != null else null)
		if shield_node != null:
			if _counter_shield:
				shield_node.take_damage(_damage, _weapon_type, _counter_shield)
				_stuck = true
				call_deferred("_deferred_reparent", area.get_parent())
				return
			_shield_bounce = true
			_dir *= -1
			var sprite = $Sprite2D
			if sprite:
				sprite.scale.x *= -1
			_gravity = 3.0
			_rot_speed *= -20.0
			return

		# 目标身上已扎入的箭矢≥8根则不插入（含建筑和棋子）
		var stuck_count = 0
		for p in get_tree().get_nodes_in_group("stuck_projectiles"):
			if is_instance_valid(p) and p.get_parent() == area.get_parent():
				stuck_count += 1
		if stuck_count >= 8:
			_die()
			return

		add_to_group("stuck_projectiles")
		area.take_damage(_damage, _weapon_type, _counter_shield)
		_swap_to_hit()
		_stuck = true
		call_deferred("_deferred_reparent", area.get_parent())


func _deferred_reparent(new_parent: Node):
	reparent(new_parent)
	z_as_relative = true
	z_index = 0
	collision_layer = 0
	collision_mask = 0
	add_to_group("stuck_projectiles")
	var shield_idx = -1
	for i in new_parent.get_child_count():
		if new_parent.get_child(i).get_node_or_null("ShieldSprite"):
			shield_idx = i
			break
	if shield_idx >= 0:
		new_parent.move_child(self, shield_idx)
