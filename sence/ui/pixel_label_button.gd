extends Control

# 像素字 Label（按钮/暗底用）
# 白色文字 + 1px 黑色右下阴影，内部居中


var text: String = "":
	set(v):
		text = v
		if _front:
			_front.text = v
			_back.text = v

var _front: Label
var _back: Label

const FONT_SIZE = 12
const SCALE = 2.0


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

	var f = preload("res://sence/ui/pixel_font.gd").get_font()

	_back = Label.new()
	_back.add_theme_font_override("font", f)
	_back.add_theme_font_size_override("font_size", FONT_SIZE)
	_back.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	_back.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_back.position = Vector2(1, 1)
	_back.anchor_right = 1.0
	_back.anchor_bottom = 1.0
	_back.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_back.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_back)

	_front = Label.new()
	_front.add_theme_font_override("font", f)
	_front.add_theme_font_size_override("font_size", FONT_SIZE)
	_front.add_theme_color_override("font_color", Color.WHITE)
	_front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_front.anchor_right = 1.0
	_front.anchor_bottom = 1.0
	_front.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_front.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_front)

	scale = Vector2(SCALE, SCALE)
