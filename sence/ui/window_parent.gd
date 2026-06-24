extends Panel


const PIXEL_LABEL = preload("res://sence/ui/pixel_label.gd")


@export var window_width: int = 400
@export var window_height: int = 300
@export var window_pos_x: int = 0
@export var window_pos_y: int = 0

var title_label
var content: MarginContainer

const BORDER = 8


func _ready() -> void:
	custom_minimum_size = Vector2(window_width, window_height)
	size = Vector2(window_width, window_height)
	position = Vector2(window_pos_x, window_pos_y)

	var tex = load("res://rescourse/object/UI/windowsui/窗口.png")
	var bg = StyleBoxTexture.new()
	bg.texture = tex
	bg.texture_margin_left = BORDER
	bg.texture_margin_top = BORDER
	bg.texture_margin_right = BORDER
	bg.texture_margin_bottom = BORDER
	bg.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	bg.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	add_theme_stylebox_override("panel", bg)

	var title_bar = ColorRect.new()
	title_bar.color = Color(0, 0, 0, 0)
	title_bar.position = Vector2(BORDER, BORDER)
	title_bar.size = Vector2(window_width - BORDER * 2, 24)
	title_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(title_bar)

	title_label = PIXEL_LABEL.new()
	title_label.text = "窗口"
	title_label.position = Vector2(8, 2)
	title_label.size = Vector2(window_width - BORDER * 2 - 8, 24)
	title_bar.add_child(title_label)

	content = MarginContainer.new()
	content.position = Vector2(BORDER, BORDER + 24)
	content.size = Vector2(window_width - BORDER * 2, window_height - BORDER - 24 - BORDER)
	add_child(content)


func set_title(text: String) -> void:
	title_label.text = text


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
