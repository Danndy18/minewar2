extends "res://sence/equipment/装备/主动道具/active_item_parent.gd"

# 方块主动道具父对象
# 持有方块时：立即无戒备、关攻击框、强制双手抬起动画、移速惩罚
# 子类重写 weight_mult 改变减速倍率
@export var weight_mult: float = 0.8

func apply_to(parent: Node) -> void:
	parent.unguarded = true
	parent.attack_area.monitoring = false

func sync(parent: Node) -> void:
	super.sync(parent)
	parent.unguarded = true
	parent.attack_area.monitoring = false
	parent.AnimaUpper.animation = "上半身-抬手"
	parent.AnimaUpper.frame = 0
	parent.effect_pool.move_speed *= weight_mult
	var spr = get_node_or_null(sprite_node) as AnimatedSprite2D
	if spr:
		spr.z_index = parent.z_index
