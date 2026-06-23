extends Resource
class_name AttackMethodData

# ============================================================
# 攻击方式数据（作为 Resource，可在 Inspector 中独立编辑）
# 每种攻击方式定义一个结构：
#   名称、权重、三段帧数、三段移速修正、三段攻速修正、伤害
# ============================================================

# 攻击方式名称（例如："横斩"、"重劈"、"刺击"）
@export var name: String = ""

# 权重：数值越高，攻击时被随机选中的概率越大
@export var weight: float = 1.0

# 动画模式（"轻攻击" / "重攻击" / "蓄力" 等，对应图包动画名前缀）
@export var anim_mode: String = "轻攻击"

# 三段攻击各自的移速修正
@export var windup_move: float = 0.8
@export var process_move: float = 0.8
@export var recovery_move: float = 0.8

# 三段攻击各自的攻速修正
@export var windup_speed: float = 1.0
@export var process_speed: float = 1.0
@export var recovery_speed: float = 1.0

# 攻击效果场景模板（在 PROCESS 阶段实例化）
@export var effect: PackedScene

# ============================================================
# 效果参数（由 effect 场景读取使用）
# aoe_damage：群体伤害值（0 则为纯单体，由最近目标吃满）
# damage_mult：伤害倍率（目前未使用，保留备用）
# range_add：攻击距离加值（比碰撞框多延伸的像素）
# ============================================================
@export var effect_aoe_damage: int = 0
@export var effect_damage_mult: float = 1.0
@export var effect_range_add: int = 0

# 破盾标记：命中举盾目标时伤害 ×10
@export var counter_shield: bool = false

# 护甲破坏持续时间（物理帧），0=不施加
@export var buff_armor_break_frames: int = 0

# 护甲破坏触发概率（0.0~1.0），0=不触发
@export var buff_armor_break_chance: float = 0.0
