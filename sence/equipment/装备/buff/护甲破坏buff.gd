extends "res://sence/equipment/装备/buff/buff_parent.gd"

const BREAK_EFFECT = preload("res://sence/equipment/特效/大碎裂效果.gd")


func _ready() -> void:
	add_to_group("buff_armor_break")
	_spawn_chip_effect()


func _buff_expired() -> void:
	remove_from_group("buff_armor_break")


func _spawn_chip_effect():
	var p = parent_node
	if not p:
		return
	var nodes = p.get("_equipment_nodes")
	if typeof(nodes) != TYPE_ARRAY:
		return
	for e in nodes:
		if not is_instance_valid(e):
			continue
		var spr = e.get_node_or_null("ArmorSprite")
		if not spr or not spr.sprite_frames:
			continue
		var count = randi() % 3
		if count == 0:
			continue
		var frame_tex = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
		if not frame_tex:
			continue
		var tex: Texture2D = frame_tex
		var region = Rect2(Vector2.ZERO, Vector2(32, 32))
		if frame_tex is AtlasTexture:
			var at = frame_tex as AtlasTexture
			tex = at.atlas
			region = at.region
		var palette_colors: Array[Color] = []
		if spr.material is ShaderMaterial:
			var m = spr.material as ShaderMaterial
			for i in range(1, 5):
				var c = m.get_shader_parameter("replace_" + str(i))
				if c is Color:
					palette_colors.append(c)
		var dir = -1 if p.camp == 0 else 1
		var slot = e.get("armor_slot")
		var chip_y = -10.0 if slot == 0 else 10.0
		var eff = Node2D.new()
		eff.set_script(BREAK_EFFECT)
		p.get_parent().add_child(eff)
		eff.global_position = spr.global_position + Vector2(0, chip_y)
		eff.setup(tex, region, dir, 0, 2, p.z_index, palette_colors, 3)
