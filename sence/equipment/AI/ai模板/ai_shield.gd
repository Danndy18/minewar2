extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AI_Shield — 盾牌使用
#
# 行为逻辑（按优先级从高到低）：
#   ① 如果自己没有盾牌 → 直接收盾（防报错）
#   ② 前方 20px 内有友军已举盾 → 收盾（有人扛了，自己不浪费体力）
#   ③ 前方 10~1000px 内有友军 → 收盾（前面有人挡着）
#   ④ 前方 1000px 内没有任何友方 → 举盾（自己就是最前面那个）
#   ⑤ 只有 0~10px 内有友军，但没人举盾 → 不关心（交给别人判断）
#
# 适用兵种：
#   所有持盾单位。常与 AI_FollowShield、AI_Charge 组合使用。
#
# 注意：
#   这个模块只关心 shield 维度，不关心 move。
# ============================================================
func evaluate(p: Node) -> Dictionary:
	# 没盾牌 → 直接收盾（防止脚本访问 _shield_instance 报错）
	if not p.get("_active_item"):
		return { "move": null, "shield": false }

	# 计算面朝方向：camp=0 向右 (+1)，camp!=0 向左 (-1)
	var dir = 1 if p.camp == 0 else -1
	var friends = p.get_tree().get_nodes_in_group("pieces")

	# has_friend_ahead：前方 10~1000px 内有友军
	# has_friend_any：前方 0~1000px 内有友军（严格意义，仅用于检测是否彻底孤立）
	var has_friend_ahead = false
	var has_friend_any = false

	for f in friends:
		if f == p or f.get("camp") != p.camp:
			continue

		var dx = f.global_position.x - p.global_position.x
		# 只考虑面朝方向的友军（不要身后的）
		if (dx * dir) > 0:
			var dist = abs(dx)
			# 超过 1000px 太远了，忽略不计
			if dist > 1000:
				continue
			has_friend_any = true

			# 优先级最高：前方 20px 内有人举盾 → 立刻收盾
			if dist < 20 and f.get("shield_raising"):
				return { "move": null, "shield": false }

			# 次高：前方 10~1000px 内有友军（不管举不举盾）
			if dist >= 10:
				has_friend_ahead = true

	# 前方 10px 外有友军 → 收盾，让前面的人扛
	if has_friend_ahead:
		return { "move": null, "shield": false }

	# 彻底孤立（1000px 内没任何友军）→ 举盾
	if not has_friend_any:
		return { "move": null, "shield": true }

	# 只有 0~10px 内有友军但没人举盾 → 不关心，让低优先级决定
	return { "move": null, "shield": null }
