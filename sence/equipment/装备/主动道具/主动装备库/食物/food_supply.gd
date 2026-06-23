extends "res://sence/equipment/装备/主动道具/主动装备库/食物/food_parent.gd"

func apply_to(pieces_parent: Node) -> void:
	food_anim_name = "food_" + str(randi() % 6 + 1)
	super.apply_to(pieces_parent)


func _on_eat_start(parent: Node) -> void:
	food_anim_name = "food_" + str(randi() % 6 + 1)
	_food_sprite.animation = food_anim_name
