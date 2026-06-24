extends Control

# 像素字 Label（居中版）
# 颜色 #565656，无投影，文字居中


var text: String = "":
	set(v):
		text = v
		if _front:
			_front.text = v

var font_color: Color = Color("#565656"):
	set(v):
		font_color = v
		if _front:
			_front.add_theme_color_override("font_color", v)

var _front: Label

const FONT_SIZE = 12
const SCALE = 2.0


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

	var f = preload("res://sence/ui/pixel_font.gd").get_font()

	_front = Label.new()
	_front.add_theme_font_override("font", f)
	_front.add_theme_font_size_override("font_size", FONT_SIZE)
	_front.add_theme_color_override("font_color", Color("#565656"))
	_front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_front.anchor_right = 1.0
	_front.anchor_bottom = 1.0
	_front.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_front.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_front)

	scale = Vector2(SCALE, SCALE)
