extends Control

# 物品槽位组件
# 固定尺寸 36x36，可叠放图标


var _icon: TextureRect
var _bg: TextureRect

const SLOT_SIZE = 36


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	size = Vector2(SLOT_SIZE, SLOT_SIZE)

	_bg = TextureRect.new()
	_bg.texture = load("res://rescourse/UI/windowsui/物品槽位.png")
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bg.stretch_mode = TextureRect.STRETCH_KEEP
	add_child(_bg)

	_icon = TextureRect.new()
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_icon.position = Vector2(2, 2)
	_icon.size = Vector2(SLOT_SIZE - 4, SLOT_SIZE - 4)
	add_child(_icon)


func set_icon(tex: Texture2D) -> void:
	_icon.texture = tex


func clear_icon() -> void:
	_icon.texture = null
