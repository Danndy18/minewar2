extends "res://sence/equipment/装备/主动道具/active_item_parent.gd"

# 盾牌耐久
@export var shield_health: int = 3
@export var max_shield_health: int = 3

# 盾牌的 ShieldSprite 节点路径
@export var shield_sprite_node: NodePath

# 盾牌自己的受击框
var _shield_hitbox: Area2D = null

# 锁存器：检测 S 键从松到按的上升沿
var _prev_held: bool = false

# 上一帧的举盾状态（检测变化）
var _prev_raised: bool = false

const BREAK_EFFECT_SCRIPT = preload("res://sence/equipment/特效/大碎裂效果.gd")


func apply_to(pieces_parent: Node) -> void:
	pieces_parent.shield_raising = false
	_setup_hitbox(pieces_parent)


func _setup_hitbox(parent: Node):
	var HITBOX_SCRIPT = preload("res://sence/equipment/ai/ai父对象/hitbox_area.gd")
	_shield_hitbox = Area2D.new()
	_shield_hitbox.set_script(HITBOX_SCRIPT)
	_shield_hitbox.collision_layer = 0
	_shield_hitbox.collision_mask = 0
	_shield_hitbox.camp = parent.camp
	_shield_hitbox.parent_node = self
	_shield_hitbox.name = "ShieldHitBox"
	var hb_shape = CollisionShape2D.new()
	var hb_rect = RectangleShape2D.new()
	hb_rect.size = Vector2(18, 20)
	hb_shape.shape = hb_rect
	hb_shape.position = Vector2(0, 6)
	_shield_hitbox.add_child(hb_shape)
	parent.add_child(_shield_hitbox)


func on_toggle_pulse(parent: Node) -> void:
	pass


func sync(parent: Node) -> void:
	super.sync(parent)

	if parent.active_item_held and not _prev_held:
		parent.shield_raising = not parent.shield_raising
	_prev_held = parent.active_item_held

	var raised = parent.shield_raising
	var ss: AnimatedSprite2D = get_node_or_null(shield_sprite_node)
	if ss:
		ss.z_index = parent.z_index

	if raised:
		parent.attack_area.monitoring = false
		parent.AnimaUpper.animation = "上半身-抬手"
		parent.AnimaUpper.frame = 0
		if not _prev_raised:
			parent.attack_state = 0
			parent.attack_state_frame = 0
			parent._attack_pending = false
			parent._attack_effect_counter = 0
			parent._attack_effect_fired = false
		if _shield_hitbox:
			_shield_hitbox.collision_layer = 4
		if parent._hitbox:
			parent._hitbox.monitoring = false
			parent._hitbox.collision_layer = 0
	else:
		if _prev_raised:
			parent.attack_area.monitoring = true
		if _shield_hitbox:
			_shield_hitbox.collision_layer = 0
		if parent._hitbox:
			parent._hitbox.monitoring = true
			parent._hitbox.collision_layer = 4

	_prev_raised = raised


func take_damage(amount: int, attacker_weapon_type: String = "", counter_shield: bool = false) -> void:
	if shield_health <= 0:
		return
	if counter_shield:
		amount *= 10
	shield_health -= amount
	if shield_health > 0:
		_play_chip_effect(get_parent())
		return

	shield_health = 0
	var parent = get_parent()
	if not parent:
		return

	if parent.shield_raising:
		parent.shield_raising = false
		parent.attack_area.monitoring = true
		if parent._hitbox:
			parent._hitbox.monitoring = true
			parent._hitbox.collision_layer = 4

	# 发射盾碎信号（触发 _restore_collision → 击退）
	parent.shield_broken.emit()

	_play_break_effect(parent)

	parent._active_item = null
	parent._equipment_nodes.erase(self)

	if _shield_hitbox:
		_shield_hitbox.queue_free()
		_shield_hitbox = null

	queue_free()


func _play_chip_effect(parent: Node):
	_spawn_fragments(parent, 3, 0, 2)


func _play_break_effect(parent: Node):
	_spawn_fragments(parent, 5, 4, 7)


func _spawn_fragments(parent: Node, chip_size: int, min_frags: int, max_frags: int):
	var ss: AnimatedSprite2D = get_node_or_null(shield_sprite_node)
	if not ss or not ss.sprite_frames:
		return
	var frame_tex = ss.sprite_frames.get_frame_texture(ss.animation, ss.frame)
	if not frame_tex:
		return
	var tex: Texture2D = frame_tex
	var region = Rect2(Vector2.ZERO, Vector2(32, 32))
	if frame_tex is AtlasTexture:
		var at = frame_tex as AtlasTexture
		tex = at.atlas
		region = at.region

	var dir = -1 if parent.camp == 0 else 1
	var palette_colors: Array[Color] = []
	if ss.material is ShaderMaterial:
		var m = ss.material as ShaderMaterial
		for i in range(1, 5):
			var c = m.get_shader_parameter("replace_" + str(i))
			if c is Color:
				palette_colors.append(c)
	var eff = Node2D.new()
	eff.set_script(BREAK_EFFECT_SCRIPT)
	parent.get_parent().add_child(eff)
	eff.global_position = ss.global_position
	eff.setup(tex, region, dir, min_frags, max_frags, parent.z_index, palette_colors, chip_size)
