static var _font: Font = null


static func get_font() -> Font:
	if not _font:
		_font = load("res://rescourse/object/UI/simsun.ttc")
	return _font
