extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AI_Gang — 群殴者
#
# 行为逻辑：
#   检查前方 30px 内是否有友军，以及后方 30px 内是否有友军。
#   如果有友军在前方，或者后方 30px 内有友军紧贴，就前进。
#   否则（孤立无援或前后无人）停住等待。
#
# 适用兵种：
#   剑士集群、拳手集群等需要抱团的近战单位。
#
# 注意：
#   这个模块只关心 move 维度，不关心 shield。
# ============================================================
func evaluate(p: Node) -> Dictionary:
	# 计算前进方向：camp=0 向右 (+1)，camp!=0 向左 (-1)
	var dir = 1 if p.camp == 0 else -1
	# 扫描所有棋子（已通过 "pieces" 组注册的）
	var friends = p.get_tree().get_nodes_in_group("pieces")
	var friend_ahead = false	# 前方有友军（任意距离）
	var near_rear = false		# 后方 30px 内有友军紧贴

	for f in friends:
		if f == p or f.get("camp") != p.camp:
			continue
		var dx = f.global_position.x - p.global_position.x
		if (dx * dir) > 0:
			# 友军在自己面朝方向的前方
			friend_ahead = true
		else:
			# 友军在自己后方，且距离 < 30px
			if abs(dx) < 30:
				near_rear = true

	# 前方有友军需要支援，或者后方有人紧贴怕被挤 → 前进
	if friend_ahead or near_rear:
		return { "move": 1, "shield": null }
	else:
		# 孤立无援，没有明确的行动目标 → 停住等待
		return { "move": 0, "shield": null }
