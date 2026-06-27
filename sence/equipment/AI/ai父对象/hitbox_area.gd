extends Area2D

var camp: int = 0
var parent_node: Node = null


func take_damage(amount: int, attacker_weapon_type: String = "", counter_shield: bool = false) -> void:
	# 如果父对象标记了 block_projectiles，检查攻击来源是否为弹射物
	if parent_node and parent_node.get("block_projectiles"):
		for area in get_overlapping_areas():
			if area.get("is_projectile"):
				return
	if parent_node and parent_node.has_method("take_damage"):
		parent_node.take_damage(amount, attacker_weapon_type, counter_shield)
