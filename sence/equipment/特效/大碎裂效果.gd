extends Node2D

const OUTLINE_SHADER = preload("res://sence/equipment/特效/fragment_outline.gdshader")
const FILL_BLACK_SHADER = preload("res://sence/equipment/特效/fragment_fill_black.gdshader")
const PALETTE_SHADER = preload("res://sence/equipment/着色/palette_swap.gdshader")

var _fragments: Array = []
var _life: float = 0.8
var _spawn_y: float = 0.0
var _use_palette: bool = false
var _replace_1: Color
var _replace_2: Color
var _replace_3: Color
var _replace_4: Color


func setup(texture: Texture2D, region: Rect2, dir_x: int = 1, min_fragments: int = 4, max_fragments: int = 7, parent_z: int = 0, palette: Array[Color] = [], chip_size: int = 5, velocity_scale: float = 1.0):
	var full_img = texture.get_image()
	var sub_img = full_img.get_region(region)

	if palette.size() == 4:
		_use_palette = true
		_replace_1 = palette[0]
		_replace_2 = palette[1]
		_replace_3 = palette[2]
		_replace_4 = palette[3]

	var pixels: Array = []
	for x in sub_img.get_width():
		for y in sub_img.get_height():
			if sub_img.get_pixel(x, y).a > 0.1:
				pixels.append(Vector2i(x, y))

	if pixels.is_empty():
		return
	_spawn_y = global_position.y

	pixels.shuffle()
	var count = randi_range(min_fragments, min(max_fragments, pixels.size()))

	for i in count:
		var cx = pixels[i].x
		var cy = pixels[i].y
		var size = randi_range(maxi(1, chip_size - 2), chip_size)
		var half = size / 2
		var rx = clampi(cx - half, 0, sub_img.get_width() - size)
		var ry = clampi(cy - half, 0, sub_img.get_height() - size)
		var frag_img = sub_img.get_region(Rect2i(rx, ry, size, size))
		if frag_img.is_empty():
			continue
		var frag_tex = ImageTexture.create_from_image(frag_img)

		var container = Node2D.new()
		container.position = Vector2(rx + half - region.size.x * 0.5, ry + half - region.size.y * 0.5)
		container.z_index = parent_z + randi_range(-1, 1)

		var offsets = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
		for off in offsets:
			var outline = Sprite2D.new()
			outline.texture = frag_tex
			outline.scale = Vector2(3, 3)
			outline.position = off * 3
			outline.material = ShaderMaterial.new()
			outline.material.shader = FILL_BLACK_SHADER
			container.add_child(outline)

		var spr = Sprite2D.new()
		spr.texture = frag_tex
		spr.scale = Vector2(3, 3)
		if _use_palette:
			var palette_mat = ShaderMaterial.new()
			palette_mat.shader = PALETTE_SHADER
			palette_mat.set_shader_parameter("replace_1", _replace_1)
			palette_mat.set_shader_parameter("replace_2", _replace_2)
			palette_mat.set_shader_parameter("replace_3", _replace_3)
			palette_mat.set_shader_parameter("replace_4", _replace_4)
			spr.material = palette_mat
		else:
			spr.material = ShaderMaterial.new()
			spr.material.shader = OUTLINE_SHADER
		container.add_child(spr)

		add_child(container)
		var vx = dir_x * randf_range(80, 180) * velocity_scale
		var vy = -randf_range(60, 120) * velocity_scale
		var spread = deg_to_rad(randf_range(-10.0, 10.0))
		var cs = cos(spread)
		var sn = sin(spread)
		_fragments.append({
			"node": container,
			"vel": Vector2(vx * cs - vy * sn, vx * sn + vy * cs),
			"rot": randf_range(-20.0, 20.0),
			"gravity": 600.0,
		})

	var tw = create_tween()
	tw.tween_interval(_life)
	tw.tween_callback(queue_free)


func _process(delta: float) -> void:
	_life -= delta
	for f in _fragments:
		if f.get("done"):
			continue
		f.vel.y += f.gravity * delta
		f.node.position += f.vel * delta
		f.node.rotation += f.rot * delta
		var f_global_y = f.node.global_position.y
		var death_y = _spawn_y + 50
		if f_global_y > death_y:
			f.node.global_position.y = death_y
			f.done = true
