extends "res://sence/equipment/装备/装备父对象/equipment_parent.gd"

# 主动装备父对象
# 子类在 sync() 中读取 parent.active_item_held 判断按键状态
# 需检测从松到按的上升沿时自行保存上一帧值做锁存器

func sync(parent: Node) -> void:
	super.sync(parent)
