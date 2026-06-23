extends Resource
class_name AIData

# ============================================================
# AI 数据基类 — 所有 AI 模块的父对象
#
# 每个 AI 模块都是一个独立的 Resource 文件，关注不同的决策维度。
# 模块之间通过 priority 决定优先级，高 priority 的决策覆盖低的。
# 模块关心的维度就返回值，不关心的就返回 null 交给低优先级。
#
# 使用方式：
#   新建一个 .gd 继承本类，实现 evaluate() 方法，
#   返回字典 { "move": ..., "shield": ... }
# ============================================================

# AI 名称，用于区分和调试
@export var ai_name: String = ""

# 优先级，数值越大越优先
# 容器（AIContainer）会按 priority 从高到低遍历所有模块，
# 对 move / shield 各维度取第一个非 null 的结果
@export var priority: int = 0

# ============================================================
# evaluate(parent_node)
# 每个决策周期调用一次，返回一个字典包含所有维度的决策：
#   {
#     "move":   1=前进, -1=后退, 0=停止, null=不关心
#     "shield": true=举盾, false=收盾, null=不关心
#   }
#
# 每个模块只**推荐**自己关心的维度，不关心的返回 null。
# 容器会合并所有模块的结果，高 priority 覆盖低 priority。
# ============================================================
func evaluate(parent_node: Node) -> Dictionary:
	return { "move": null, "shield": null, "cooldown": null, "auto_skill": null }
