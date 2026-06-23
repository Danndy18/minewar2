extends "res://sence/equipment/装备/装备父对象/equipment_parent.gd"

# 武器贴图
@export var weapon_frames: SpriteFrames

# 武器类型标识（"剑"/"斧"/"弓"等）
@export var weapon_type: String = ""

# 攻击方式列表，按权重随机择取
@export var attack_methods: Array[AttackMethodData] = []

# 攻击范围（覆盖棋子默认值）
@export var attack_range: float = 12.0

# 基础攻击力
@export var damage: int = 1

# 是否让棋子使用持物站立姿态
# 拳头/空手应设为 false，保持空手站立姿势
@export var use_weapon_stance: bool = true

# 当前攻击周期选中的攻击方式
var _current_method: AttackMethodData = null


func apply_to(pieces_parent: Node) -> void:
	if use_weapon_stance:
		pieces_parent._has_weapon = true
	pieces_parent.attack_range = attack_range
	var ws: AnimatedSprite2D = get_node_or_null("WeaponSprite")
	if ws and weapon_frames:
		ws.sprite_frames = weapon_frames
		ws.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_apply_palette(ws)


func sync(parent: Node) -> void:
	super.sync(parent)
	if parent.attack_state == 1 and parent.attack_state_frame == 0:
		_on_windup_start(parent)


func _on_windup_start(parent: Node) -> void:
	var method = _pick_attack_method()
	if method == null:
		return
	parent._attack_anim_type = method.anim_mode
	parent._attack_windup_speed = method.windup_speed
	parent._attack_process_speed = method.process_speed
	parent._attack_recovery_speed = method.recovery_speed
	parent._attack_windup_move = method.windup_move
	parent._attack_process_move = method.process_move
	parent._attack_recovery_move = method.recovery_move
	_current_method = method


# 由棋子每帧检查效果阈值，到达时调用此方法生成一次攻击判定
func spawn_effect(parent: Node) -> void:
	if _current_method == null or not _current_method.effect:
		return
	var inst = _current_method.effect.instantiate()
	inst.setup(parent, {
		aoe_damage = _current_method.effect_aoe_damage,
		damage_mult = _current_method.effect_damage_mult,
		range_current = parent.attack_range_current,
		range_add = _current_method.effect_range_add,
		weapon_damage = damage,
		weapon_type = weapon_type,
		counter_shield = _current_method.counter_shield,
		buff_armor_break_frames = _current_method.buff_armor_break_frames,
		buff_armor_break_chance = _current_method.buff_armor_break_chance,
	})
	inst.position.x += -20
	parent.add_child(inst)


func _pick_attack_method() -> AttackMethodData:
	if attack_methods.is_empty():
		return null
	var total: float = 0.0
	for m in attack_methods:
		total += m.weight
	var roll = randf_range(0.0, total)
	var acc: float = 0.0
	for m in attack_methods:
		acc += m.weight
		if roll <= acc:
			return m
	return attack_methods.back()
