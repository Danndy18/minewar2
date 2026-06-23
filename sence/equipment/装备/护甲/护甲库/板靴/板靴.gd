extends "res://sence/equipment/装备/护甲/护甲父对象/armor.gd"


func apply_to(pieces_parent: Node) -> void:
	super(pieces_parent)
	pieces_parent._visual_bounce_enabled = false
	pieces_parent._knockback_threshold_mult_base = 100.0
	pieces_parent._impact_threshold_mult_base = 100.0
