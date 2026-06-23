extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AI_FollowShield — 跟紧盾牌
#
# 行为逻辑：
#   扫描前方友军，如果发现有人举盾：
#   - 10px 内有人举盾 → move=-1（后退，太近了）
#   - 40px 内有人举盾 → move=0（停，保持距离）
#   前方没人举盾 → 不关心，让低优先级决定 move
#
# 设计意图：
#   高优先级（p=200），确保任何持盾兵都不会挤到前面的扛盾兵。
#   后面的兵看到盾牌会自觉停住或后退，形成梯队。
#
# 注意：
#   这个模块同时影响 move 和 shield 两个维度。
#   它让跟盾的人同时收盾，省得后面的人也举盾浪费体力。
# ============================================================
func evaluate(p: Node) -> Dictionary:
	# 面朝方向：camp=0 向右 (+1)，camp!=0 向左 (-1)
	var dir = 1 if p.camp == 0 else -1
	var friends = p.get_tree().get_nodes_in_group("pieces")

	for f in friends:
		# 跳过自己、跳过不同阵营的
		if f == p or f.get("camp") != p.camp:
			continue

		var dx = f.global_position.x - p.global_position.x
		# 友军在自己面朝方向的前方，且正在举盾
		if (dx * dir) > 0 and f.get("shield_raising"):
			var dist = abs(dx)
			# 10px 内有人举盾 → 太近了，后退并收盾
			if dist < 10:
				return { "move": -1, "shield": null }
			# 40px 内有人举盾 → 保持距离，停住
			if dist < 40:
				return { "move": 0, "shield": null }

	# 前方没人举盾 → 不关心，让低优先级决定
	return { "move": null, "shield": null }
