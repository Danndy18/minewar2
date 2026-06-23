extends Area2D

var _parent = null
var _aoe_damage: int = 1
var _damage_mult: float = 1.0
var _weapon_damage: int = 0
var _weapon_type: String = ""
var _counter_shield: bool = false
var _buff_armor_break_frames: int = 0
var _buff_armor_break_chance: float = 0.0
var _lifetime_frame: int = 6
var _done: bool = false


func setup(parent: Node, cfg: Dictionary):
	_parent = parent
	_aoe_damage = cfg.get("aoe_damage", 1)
	_damage_mult = cfg.get("damage_mult", 1.0)
	_weapon_damage = cfg.get("weapon_damage", 0)
	_weapon_type = cfg.get("weapon_type", "")
	_counter_shield = cfg.get("counter_shield", false)
	_buff_armor_break_frames = cfg.get("buff_armor_break_frames", 0)
	_buff_armor_break_chance = cfg.get("buff_armor_break_chance", 0.0)

	var col = $CollisionShape2D
	var effective = cfg.get("range_current", 20.0) + cfg.get("range_add", 0)
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(effective * 0.5, 8.0)
	col.shape = rect

	var col_pos = cfg.get("range_current", 20.0) * 0.5 + cfg.get("range_add", 0) * 0.5 + 20
	col.position = Vector2(col_pos, 10)


func _physics_process(delta: float) -> void:
	if not _done:
		_lifetime_frame -= 1
		if _lifetime_frame == 1:
			_apply_buff()
		if _lifetime_frame <= 0:
			_apply_damage()
			_done = true
			queue_free()


func _apply_damage():
	if not _parent: return
	var bodies = _get_hit_areas()
	if bodies.is_empty(): return

	var closest = null
	var closest_dist = INF
	for b in bodies:
		var d = abs(b.global_position.x - _parent.global_position.x)
		if d < closest_dist:
			closest_dist = d
			closest = b

	if closest:
		var single = int(_weapon_damage * _damage_mult)
		closest.take_damage(single, _weapon_type, _counter_shield)

	for b in bodies:
		b.take_damage(_aoe_damage, _weapon_type, _counter_shield)


func _apply_buff():
	if not _parent: return
	var bodies = _get_hit_areas()
	if bodies.is_empty(): return

	for b in bodies:
		if randf() >= _buff_armor_break_chance:
			continue
		var target = b.get("parent_node")
		if target and _buff_armor_break_frames > 0 and target.has_method("add_buff"):
			target.add_buff("armor_break", _buff_armor_break_frames)



func _get_hit_areas() -> Array:
	var out: Array = []
	for area in get_overlapping_areas():
		if area.get("camp") != null and area.get("camp") != _parent.camp:
			out.append(area)
	return out
