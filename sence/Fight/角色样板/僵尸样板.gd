extends "res://script/pieces_parent.gd"

@export var template_health_limit: float = 20.0
@export var template_move_speed: float = 1200.0
@export var template_attack_range: float = 12.0
@export var template_knockback_threshold: float = 0.5
@export var template_impact_threshold: float = 0.33
@export var template_knockback_pixels: float = 12000.0
@export var template_knockback_duration: float = 0.33
@export var template_taken_base: float = 1.0
@export var template_armor_speed_penalty: float = 1.0

func _ready() -> void:
	health_limit = template_health_limit
	health_current = template_health_limit
	move_speed = template_move_speed
	attack_range = template_attack_range
	knockback_threshold = template_knockback_threshold
	impact_threshold = template_impact_threshold
	knockback_pixels = template_knockback_pixels
	knockback_duration = template_knockback_duration
	_taken_base = template_taken_base
	_armor_speed_penalty = template_armor_speed_penalty
	_anim_overrides = {"上半身-站立-空手": "上半身-抬手", "上半身-行走": "上半身-抬手"}
	_attack_anim_overrides = {"前摇": ["上半身-抬手-挥舞", true], "生效区间": ["上半身-抬手-挥舞", false], "后摇": ["上半身-抬手", false]}
	super()