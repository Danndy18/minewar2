extends "res://sence/equipment/装备/主动道具/active_item_parent.gd"

@export var food_count: int = 1
@export var food_volume: int = 5
@export var food_effect: Resource = null
@export var is_solid: bool = true
@export var food_anim_name: String = "food_1"

var _eat_timer: float = 3.0
var _chew_count: int = 0
var _await_release: bool = false
var _pending_remove: bool = false

@onready var _food_sprite: AnimatedSprite2D = $FoodSprite


func get_outline_pairs() -> Array:
	if _food_sprite and outline_frames:
		return [[_food_sprite, outline_frames]]
	return []


func apply_to(pieces_parent: Node) -> void:
	_food_sprite.visible = false


func sync(parent: Node) -> void:
	super.sync(parent)

	if _pending_remove:
		parent._eating_active = false
		parent._active_item = null
		parent._equipment_nodes.erase(self)
		queue_free()
		return

	if parent.active_item_held:
		parent._block_attack = true
		if _await_release:
			_food_sprite.visible = false
			parent._eating_active = false
			return

		if not _food_sprite.visible:
			_food_sprite.visible = true
			_food_sprite.animation = food_anim_name
			_eat_timer = 3.0
			_chew_count = 0
			parent._eating_active = true
			_on_eat_start(parent)

		_food_sprite.z_index = parent.z_index
		parent.effect_pool.move_speed *= 0.5

		_eat_timer -= 0.2
		if _eat_timer < 0.0:
			_eat_timer += 3.0
			_chew_count += 1
			if is_solid:
				_play_chip(parent)
			if _chew_count >= food_volume:
				_consume(parent)

		var frame = clampi(int(_eat_timer), 0, 2)

		_food_sprite.frame = frame
		parent._eating_frame = frame
	else:
		if _food_sprite.visible:
			_food_sprite.visible = false
		_eat_timer = 3.0
		_chew_count = 0
		_await_release = false
		parent._eating_active = false


func _consume(parent: Node) -> void:
	food_count -= 1
	_chew_count = 0
	_eat_timer = 3.0
	_await_release = true
	_spawn_fragments(parent, 5, 5, 2)

	if food_effect:
		var effect = food_effect.duplicate()
		effect.parent_node = parent
		parent.add_child(effect)

	parent.add_buff("saturation", 500, {"heal": 0.03, "speed": 1.2})

	if food_count <= 0:
		_pending_remove = true

	parent._eat_cooldown = 9
	parent.force_ai_decision()


func _play_chip(parent: Node) -> void:
	if not _food_sprite or not _food_sprite.sprite_frames:
		return
	var frame_tex = _food_sprite.sprite_frames.get_frame_texture(_food_sprite.animation, _food_sprite.frame)
	if not frame_tex:
		return
	var tex: Texture2D
	var region: Rect2
	if frame_tex is AtlasTexture:
		var at = frame_tex as AtlasTexture
		tex = at.atlas
		region = at.region
	else:
		tex = frame_tex
		region = Rect2(Vector2.ZERO, Vector2(64, 32))

	var dir = -1 if parent.camp == 0 else 1
	var palette: Array[Color] = []

	const BREAK_EFFECT = preload("res://sence/equipment/特效/大碎裂效果.gd")
	var eff = Node2D.new()
	eff.set_script(BREAK_EFFECT)
	parent.get_parent().add_child(eff)
	eff.global_position = _food_sprite.global_position
	eff.setup(tex, region, dir, 1, 1, parent.z_index, palette, 2)


func _spawn_fragments(parent: Node, min_count: int, max_count: int, chip_size: int) -> void:
	if not _food_sprite or not _food_sprite.sprite_frames:
		return
	var frame_tex = _food_sprite.sprite_frames.get_frame_texture(_food_sprite.animation, _food_sprite.frame)
	if not frame_tex:
		return
	var tex: Texture2D
	var region: Rect2
	if frame_tex is AtlasTexture:
		var at = frame_tex as AtlasTexture
		tex = at.atlas
		region = at.region
	else:
		tex = frame_tex
		region = Rect2(Vector2.ZERO, Vector2(64, 32))

	var dir = -1 if parent.camp == 0 else 1
	var palette: Array[Color] = []

	const BREAK_EFFECT = preload("res://sence/equipment/特效/大碎裂效果.gd")
	var eff = Node2D.new()
	eff.set_script(BREAK_EFFECT)
	parent.get_parent().add_child(eff)
	eff.global_position = _food_sprite.global_position
	eff.setup(tex, region, dir, min_count, max_count, parent.z_index, palette, chip_size)


# 子类可重写此方法在每次进食开始时做额外处理
func _on_eat_start(parent: Node) -> void:
	pass
