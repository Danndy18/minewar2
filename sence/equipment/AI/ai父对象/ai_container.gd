extends "res://sence/equipment/AI/ai父对象/ai_data.gd"

# ============================================================
# AIContainer — AI 组合容器
#
# 作用：
#   把多个 AI 模块（AIData 子类）组合在一起，按优先级遍历，
#   对每个维度（move / shield）取第一个非 null 的值作为最终决策。
#
# 原理：
#   每个决策周期，容器会 **遍历所有子模块** 调用 evaluate()，
#   所有模块都跑一遍，然后按优先级合并：
#   - 高优先级的模块可以覆盖低优先级的决策
#   - 任何一个模块都不关心的维度，交给更低优先级的决定
#
# 例如「持盾冲锋者」(ai_shield_charge_follow.tres)：
#   modules = [
#     AI_FollowShield (p=200),   # 跟紧盾牌，决定 move
#     AI_Shield       (p=100),   # 举盾/收盾，决定 shield
#     AI_Charge       (p=-1),    # 兜底：没人管时就往前走
#   ]
#   每帧都会跑三个模块，move 取 p=200 的结果，shield 取 p=100 的结果
# ============================================================

# 子模块数组，每个元素是一个 AIData Resource（.tres 文件）
@export var modules: Array[Resource] = []


# ============================================================
# _get_sorted_modules()
# 将 modules 按 priority 从高到低排序
# 确保高优先级的模块先被遍历，先填进合并结果
# ============================================================
func _get_sorted_modules() -> Array:
	var sorted = modules.duplicate()
	sorted.sort_custom(func(a, b): return a.priority > b.priority)
	return sorted


# ============================================================
# evaluate(parent_node)
# 遍历所有子模块，每个都独立跑一遍 evaluate()，然后合并：
#   1. 按 priority 从高到低遍历
#   2. 对每个维度 (move, shield)，第一个非 null 的值就是最终决策
#   3. 如果所有模块的 move 都是 null，默认返回 0（停止）
# ============================================================
func evaluate(parent_node: Node) -> Dictionary:
	# 初始化结果字典，所有维度都是 null
	var result = { "move": null, "shield": null, "cooldown": null, "auto_skill": null }
	# 按优先级从高到低遍历所有子模块
	for module in _get_sorted_modules():
		var module_result = module.evaluate(parent_node)
		# 对每个维度，如果当前结果还是 null 且子模块有值，就填进去
		for key in result:
			if result[key] == null and module_result.get(key) != null:
				result[key] = module_result.get(key)
	# 兜底：如果所有模块都不关心 move，默认停住
	if result.move == null:
		result.move = 0
	return result
