extends "res://sence/equipment/装备/装备父对象/equipment_parent.gd"

# 护甲部位枚举
enum Slot { UPPER, LOWER }

# 护甲部位：UPPER = 跟随上半身，LOWER = 跟随下半身
@export var armor_slot: int = Slot.UPPER

# 基础承伤倍率
@export var damage_taken: float = 1.0

# 移速惩罚
@export var speed_penalty: float = 1.0

# 护甲贴图
@export var armor_frames: SpriteFrames

# ============================================================
# 装备时调用：将护甲属性写入棋子父对象
# ============================================================
func apply_to(pieces_parent: Node) -> void:
	var ar: AnimatedSprite2D = get_node_or_null("ArmorSprite")
	if ar and armor_frames:
		ar.sprite_frames = armor_frames
		_apply_palette(ar)


func sync(parent: Node) -> void:
	var effective_dt = damage_taken
	for b in parent._active_buffs:
		if b.id == "armor_break":
			effective_dt = 0.5 * damage_taken + 0.5
			break
	parent.effect_pool.damage_taken *= effective_dt  # [池] 护甲承伤
	parent.effect_pool.move_speed *= speed_penalty  # [池] 护甲减速
	var ar = get_node_or_null("ArmorSprite")
	if not ar or not ar.sprite_frames:
		return
	var target = parent.AnimaUpper if armor_slot == 0 else parent.AnimaLower
	ar.animation = target.animation
	ar.frame = target.frame
	ar.rotation = target.rotation


func get_equipment_sprites() -> Array:
	var ar = get_node_or_null("ArmorSprite")
	return [ar] if ar else []


func get_outline_pairs() -> Array:
	var ar = get_node_or_null("ArmorSprite")
	if ar and outline_frames:
		return [[ar, outline_frames]]
	return []
