extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AI_Eat — 吃东西
#
# 行为逻辑：
#   血量 ≥ 50% 或 _eat_cooldown > 0 → 不吃（auto_skill=false），不干涉移动
#   敌人距 < 攻击范围+50px       → 有威胁，不吃
#   敌人距 攻击范围+50px ~ 300px → 一般安全，边吃边退
#   敌人距 ≥ 300px 或无敌人      → 很安全，边吃边走（不干涉移动，交给低优先级）
#
# 优先级建议：
#   150（高于 hit_and_run=80 和 shield=40，低于 follow_shield=200）
# ============================================================

func evaluate(p: Node) -> Dictionary:
	if p._eat_cooldown > 0:
		return { "move": null, "shield": null, "cooldown": null, "auto_skill": false }

	var hp_threshold = p.health_limit * 0.5
	if p.health_current >= hp_threshold:
		return { "move": null, "shield": null, "cooldown": null, "auto_skill": false }

	var danger_range = p.attack_range_current * 3 + 100.0
	var safe_range = 900.0
	var all_pieces = p.get_tree().get_nodes_in_group("pieces")
	var nearest_dx = -1.0
	for f in all_pieces:
		if f == p or f.get("camp") == p.camp:
			continue
		var dx = abs(p.global_position.x - f.global_position.x)
		if nearest_dx < 0 or dx < nearest_dx:
			nearest_dx = dx

	if nearest_dx >= 0 and nearest_dx < danger_range:
		return { "move": null, "shield": null, "cooldown": null, "auto_skill": false }

	if nearest_dx >= 0 and nearest_dx < safe_range:
		return { "move": -1, "shield": null, "cooldown": 20, "auto_skill": true }

	return { "move": null, "shield": null, "cooldown": 20, "auto_skill": true }
