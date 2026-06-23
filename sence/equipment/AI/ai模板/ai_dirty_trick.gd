extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AI_DirtyTrick — 下作手段
#
# 行为逻辑：
#   敌人进入 240px（≈80格×3倍缩放）范围时，按住 S + 决策冷却 25 帧。
#   25 帧后重决策松开，发射弩箭。
#   射完即永久关闭（_dirty_trick_used=true），不再触发。
#
# 优先级建议：
#   150（高于 hit_and_run=80，低于 eat=150 同级）
# ============================================================

func evaluate(p: Node) -> Dictionary:
	if p._dirty_trick_used:
		return { "move": null, "shield": null, "cooldown": null, "auto_skill": null }

	var all_pieces = p.get_tree().get_nodes_in_group("pieces")
	for f in all_pieces:
		if f == p or f.get("camp") == p.camp:
			continue
		var dx = abs(p.global_position.x - f.global_position.x)
		if dx < 240.0:
			p._dirty_trick_used = true
			return { "move": null, "shield": null, "cooldown": 25, "auto_skill": true }

	return { "move": null, "shield": null, "cooldown": null, "auto_skill": null }
