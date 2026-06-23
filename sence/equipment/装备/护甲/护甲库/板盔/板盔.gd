extends "res://sence/equipment/装备/护甲/护甲父对象/armor.gd"

@export var durability: int = 1

const BREAK_EFFECT_SCRIPT = preload("res://sence/equipment/特效/大碎裂效果.gd")


func apply_to(pieces_parent: Node) -> void:
	super(pieces_parent)
	pieces_parent._helmet_armor = self


func on_helmet_blocked(parent: Node) -> void:
	durability -= 1
	if durability > 0:
		_play_chip_effect(parent)
		return
	_play_break_effect(parent, 5)
	parent._helmet_armor = null
	parent._equipment_nodes.erase(self)
	queue_free()


func _play_chip_effect(parent: Node):
	_play_break_effect(parent, 3, 0, 2)


func _play_break_effect(parent: Node, chip_size: int = 5, min_frags: int = 2, max_frags: int = 4):
	var spr: AnimatedSprite2D = get_node_or_null("ArmorSprite")
	if not spr or not spr.sprite_frames:
		return
	var frame_tex = spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
	if not frame_tex:
		return
	var tex: Texture2D = frame_tex
	var region = Rect2(Vector2.ZERO, Vector2(32, 32))
	if frame_tex is AtlasTexture:
		var at = frame_tex as AtlasTexture
		tex = at.atlas
		region = at.region
	var dir = -1 if parent.camp == 0 else 1
	var palette_colors: Array[Color] = []
	if spr.material is ShaderMaterial:
		var m = spr.material as ShaderMaterial
		for i in range(1, 5):
			var c = m.get_shader_parameter("replace_" + str(i))
			if c is Color:
				palette_colors.append(c)
	var eff = Node2D.new()
	eff.set_script(BREAK_EFFECT_SCRIPT)
	parent.get_parent().add_child(eff)
	eff.global_position = spr.global_position
	eff.setup(tex, region, dir, min_frags, max_frags, parent.z_index, palette_colors, chip_size)
