extends Node2D

const OUTLINE_BREATHE = preload("res://sence/equipment/特效/outline_breathe.gdshader")

var _outline_map: Dictionary = {}

func setup(template: Dictionary) -> void:
	_clear_all()

	var upper = $Upper as AnimatedSprite2D
	var lower = $Lower as AnimatedSprite2D
	var def = preload("res://rescourse/object/character/humanlike/player_pieces/def/def.tres")

	upper.sprite_frames = def
	upper.texture_filter = TEXTURE_FILTER_NEAREST
	upper.animation = "上半身-站立-空手"
	upper.frame = 0
	upper.position = Vector2(0, 1)

	lower.sprite_frames = def
	lower.texture_filter = TEXTURE_FILTER_NEAREST
	lower.animation = "下半身-停滞"
	lower.frame = 0
	lower.position = Vector2(0, 1)

	# 武器
	var weapon_entry = template.get("weapon")
	var has_weapon = false
	if weapon_entry and weapon_entry.get("ps"):
		has_weapon = true
		var wp = weapon_entry.ps.instantiate()
		add_child(wp)
		var frames: SpriteFrames = wp.get("weapon_frames")
		if frames:
			var wps = AnimatedSprite2D.new()
			wps.sprite_frames = frames
			wps.frame = 0
			wps.z_index = 3
			wps.texture_filter = TEXTURE_FILTER_NEAREST
			if wp.has_method("_apply_palette"):
				wp._apply_palette(wps)
			var wof = wp.get("outline_frames") as SpriteFrames
			if wof:
				_make_outline(wps, wof)
			add_child(wps)
		remove_child(wp)
		wp.queue_free()
		# 检查是否是拳（无武器姿态）
		if weapon_entry.ps.resource_path.find("拳") != -1:
			has_weapon = false

	if has_weapon:
		upper.animation = "上半身-站立-持物"

	# 加载装备（护甲/头盔/靴子/盾牌）
	var equip_order = [
		["armor", "armor_frames", "ArmorSprite", 2],
		["helmet", "armor_frames", "ArmorSprite", 1],
		["boots", "armor_frames", "ArmorSprite", 0],
		["active", "", "ShieldSprite", 4],
	]
	for item in equip_order:
		var key = item[0] as String
		var frames_prop = item[1] as String
		var sprite_name = item[2] as String
		var z_index = item[3] as int
		var entry = template.get(key)
		if not entry or not entry.get("ps"):
			continue
		var equip = entry.ps.instantiate()
		add_child(equip)
		var frames: SpriteFrames = equip.get(frames_prop)
		if not frames:
			var spr = equip.get_node_or_null(sprite_name) as AnimatedSprite2D
			if spr:
				frames = spr.sprite_frames
		if not frames:
			remove_child(equip)
			equip.queue_free()
			continue
		var new_spr = AnimatedSprite2D.new()
		new_spr.sprite_frames = frames
		new_spr.frame = 0
		new_spr.z_index = z_index
		new_spr.texture_filter = TEXTURE_FILTER_NEAREST
		if equip.has_method("_apply_palette"):
			equip._apply_palette(new_spr)
		# 描边
		var of = equip.get("outline_frames") as SpriteFrames
		if not of and equip.has_method("get_outline_pairs"):
			var pairs = equip.get_outline_pairs()
			if pairs.size() > 0:
				of = pairs[0][1]
		if of:
			_make_outline(new_spr, of)
		add_child(new_spr)
		remove_child(equip)
		equip.queue_free()

	# 身体描边
	var def_outline = preload("res://rescourse/object/character/humanlike/player_pieces/def/def_outline.tres")
	_make_outline(upper, def_outline)
	_make_outline(lower, def_outline)


func _apply_weapon_stance(has_weapon: bool) -> void:
	var upper = $Upper as AnimatedSprite2D
	if has_weapon:
		upper.animation = "上半身-站立-持物"
	else:
		upper.animation = "上半身-站立-空手"
	upper.frame = 0


func _make_outline(main: AnimatedSprite2D, of: SpriteFrames) -> void:
	var ol = AnimatedSprite2D.new()
	ol.sprite_frames = of
	ol.animation = main.animation
	ol.frame = main.frame
	ol.scale = main.scale
	ol.position = main.position
	ol.modulate = Color.BLACK
	ol.texture_filter = TEXTURE_FILTER_NEAREST
	ol.material = ShaderMaterial.new()
	ol.material.shader = OUTLINE_BREATHE
	add_child(ol)
	move_child(ol, 0)
	_outline_map[main] = ol


func _clear_all() -> void:
	for c in get_children():
		if c.name == "Lower" or c.name == "Upper":
			continue
		c.queue_free()
	_outline_map.clear()
