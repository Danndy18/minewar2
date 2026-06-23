extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AI_HitAndRun — 拉扯战术
#
# 行为逻辑：
#   攻击范围内最近敌人处于 90%~100% 区间（刚进入范围末端）→ 停止（move=0）
#   攻击范围内最近敌人处于 0%~90% 区间（太近了）→ 后退（move=-1）
#   攻击范围内无敌人 → 不关心（move=null），交给低优先级决定
#
# 设计意图：
#   让单位保持在射程边缘输出，不扎进人群。
#
# 适用兵种：
#   弓手（保持距离）、剑士（一击脱离）、所有远程/近战拉扯单位
#
# 优先级建议：
#   80（高于 gang=50 和 shield=100，低于 follow_shield=200）
# ============================================================
func evaluate(p: Node) -> Dictionary:
	var attack_range = p.attack_range_current * 3
	if attack_range <= 0:
		return { "move": null, "shield": null }

	var all_pieces = p.get_tree().get_nodes_in_group("pieces")
	var nearest_dx = -1.0
	for f in all_pieces:
		if f == p or f.get("camp") == p.camp:
			continue
		var dx = abs(p.global_position.x - f.global_position.x)
		if dx < attack_range and (nearest_dx < 0 or dx < nearest_dx):
			nearest_dx = dx

	if nearest_dx < 0:
		return { "move": null, "shield": null }

	var ratio = nearest_dx / attack_range
	if ratio > 0.9:
		return { "move": 0, "shield": null }
	else:
		return { "move": -1, "shield": null }
