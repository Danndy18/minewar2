extends Area2D

var camp: int = 0
var parent_node: Node = null


func take_damage(amount: int, attacker_weapon_type: String = "", counter_shield: bool = false) -> void:
	if parent_node and parent_node.has_method("take_damage"):
		parent_node.take_damage(amount, attacker_weapon_type, counter_shield)
