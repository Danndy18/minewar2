extends Node2D

# 建筑父对象 — 没有速度、没有攻击、没有 AI
# 进场阶段一碰就碎；常态化阶段开始工作

@export var frames: SpriteFrames
@export var outline_frames: SpriteFrames
@export var health_limit: float = 100.0
@export var hitbox_size: Vector2 = Vector2(18, 14)
@export var hitbox_offset: Vector2 = Vector2(0, 3)

var camp: int = 0
var health_current: float
var _taken_base: float = 1.0
var _pending_damage: int = 0
var _dying: bool = false

var effect_pool: Dictionary = {
	damage_taken = 1.0,
}

var _phase: String = "entry"  # "entry" → "normal"
var block_projectiles: bool = true
var _hitbox: Area2D = null
var _proximity_area: Area2D = null

var is_selected := false
var selection_marker: Node = null

var _outline_layer: Node2D
var _outline_map: Dictionary = {}
var _outline_base: Dictionary = {}

const SELECTION_MARKER = preload("res://sence/Fight/selection_marker.tscn")
const OUTLINE_BREATHE = preload("res://sence/equipment/特效/outline_breathe.gdshader")
const CHIP_EFFECT = preload("res://sence/equipment/特效/大碎裂效果.gd")


func _ready() -> void:
	health_current = health_limit

	if frames:
		var spr = $Sprite as AnimatedSprite2D
		if spr:
			spr.sprite_frames = frames
			spr.texture_filter = TEXTURE_FILTER_NEAREST
			spr.animation = "进场"
			spr.frame = 0
			spr.play()
			spr.animation_finished.connect(_on_entry_finished)

	selection_marker = SELECTION_MARKER.instantiate()
	selection_marker.visible = false
	add_child(selection_marker)

	# 建筑不翻转朝向（固定朝向）
	scale.x = abs(scale.x)

	# z_index 基于阵营
	z_index = 3

	# 创建受击框
	var HITBOX_SCRIPT = preload("res://sence/equipment/ai/ai父对象/hitbox_area.gd")
	_hitbox = Area2D.new()
	_hitbox.set_script(HITBOX_SCRIPT)
	_hitbox.collision_layer = 4
	_hitbox.collision_mask = 1
	_hitbox.camp = camp
	_hitbox.parent_node = self
	_hitbox.name = "HitBox"
	var hb_shape = CollisionShape2D.new()
	var hb_rect = RectangleShape2D.new()
	hb_rect.size = hitbox_size
	hb_shape.shape = hb_rect
	hb_shape.position = hitbox_offset
	hb_shape.debug_color = Color(0, 1, 0, 0.2)
	_hitbox.add_child(hb_shape)
	add_child(_hitbox)

	# 邻近检测 Area2D
	_proximity_area = Area2D.new()
	_proximity_area.collision_layer = 128
	_proximity_area.collision_mask = 128
	_proximity_area.set_meta("camp", camp)
	_proximity_area.area_entered.connect(_on_proximity_area_entered)
	_proximity_area.area_exited.connect(_on_proximity_area_exited)
	var prox_shape = CollisionShape2D.new()
	var prox_rect = RectangleShape2D.new()
	prox_rect.size = Vector2(18.6, 20.6)
	prox_shape.shape = prox_rect
	prox_shape.position = Vector2(0, 6)
	_proximity_area.add_child(prox_shape)
	add_child(_proximity_area)

	add_to_group("pieces")

	_setup_outline_system()


func _physics_process(delta: float) -> void:
	_process_pending_damage()


func _process_pending_damage():
	if _pending_damage <= 0:
		return
	var amount = _pending_damage * effect_pool.damage_taken * _taken_base
	_pending_damage = 0
	if amount <= 0.0:
		return
	amount = maxf(1.0, amount)
	if _phase == "entry":
		_die()
		return
	health_current -= amount
	_spawn_chips(amount)
	if health_current <= 0 and not _dying:
		_die()


func take_damage(amount: int, attacker_weapon_type: String = "", counter_shield: bool = false):
	if health_current <= 0:
		return
	_pending_damage += amount


func _die():
	_dying = true
	if _hitbox:
		_hitbox.monitoring = false
	_spawn_chips(40.0)
	# 3个大块（3-6px），每个随机方向散落
	for _i in range(3):
		_spawn_chip_set(1, 6, 0.3, true)
	# 8个小块（1-3px），正常飞出
	_spawn_chip_set(8, 3, 1.0)
	queue_free()


func _on_proximity_area_entered(area: Area2D) -> void:
	pass

func _on_proximity_area_exited(area: Area2D) -> void:
	pass


func _on_entry_finished():
	_phase = "normal"
	var spr = $Sprite as AnimatedSprite2D
	if spr:
		spr.animation = "待机"
		spr.frame = 0
		spr.play()
	_on_normal_start()


# 子类重写此方法，在进入常态化后启动功能
func _on_normal_start():
	pass


func flash_red(duration: float = 0.1, intensity: float = 1.0):
	var spr = $Sprite as AnimatedSprite2D
	if not spr:
		return
	spr.self_modulate = Color(3.0 * intensity, 0.3, 0.3, 1.0)
	var tw = create_tween()
	tw.tween_property(spr, "self_modulate", Color(1, 1, 1, 1), duration)


func select():
	is_selected = true
	if selection_marker:
		selection_marker.visible = true

func deselect():
	is_selected = false
	if selection_marker:
		selection_marker.visible = false


func _spawn_chips(amount: float):
	var raw = amount * 0.2
	var base = int(raw)
	var chance = raw - base
	var count = base + (1 if randf() < chance else 0)
	if count <= 0:
		return
	_spawn_chip_set(count, 3, 1.0)


func _spawn_chip_set(count: int, chip_size: int, velocity_scale: float, random_dir: bool = false):
	if count <= 0:
		return
	var spr = $Sprite as AnimatedSprite2D
	if not spr or not spr.sprite_frames:
		return
	var frame_tex = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
	if not frame_tex:
		return
	var tex: Texture2D = frame_tex
	var region: Rect2
	if frame_tex is AtlasTexture:
		var at = frame_tex as AtlasTexture
		tex = at.atlas
		region = at.region
	else:
		region = Rect2(Vector2.ZERO, frame_tex.get_size())
	var dir = -1 if camp == 0 else 1
	if random_dir:
		dir = 1 if randf() < 0.5 else -1
	var eff = Node2D.new()
	eff.set_script(CHIP_EFFECT)
	get_parent().add_child(eff)
	eff.global_position = spr.global_position + Vector2(randf_range(-3.5, 3.5), randf_range(-3.5, 3.5))
	eff.setup(tex, region, dir, count, count, z_index, [] as Array[Color], chip_size, velocity_scale)


func _setup_outline_system():
	if not outline_frames:
		return
	var spr = $Sprite as AnimatedSprite2D
	if not spr:
		return
	_outline_layer = Node2D.new()
	_outline_layer.name = "OutlineLayer"
	add_child(_outline_layer)
	move_child(_outline_layer, 0)
	var ol = AnimatedSprite2D.new()
	ol.sprite_frames = outline_frames
	ol.animation = spr.animation
	ol.frame = spr.frame
	ol.scale = spr.scale
	ol.position = spr.position
	ol.modulate = Color.BLACK
	ol.texture_filter = TEXTURE_FILTER_NEAREST
	ol.material = ShaderMaterial.new()
	ol.material.shader = OUTLINE_BREATHE
	_outline_layer.add_child(ol)
	_outline_map[spr] = ol
	_outline_base[spr] = spr.position
