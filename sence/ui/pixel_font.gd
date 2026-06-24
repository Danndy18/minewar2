static var _font: Font = null
static var _spaced: Font = null


static func get_font() -> Font:
	if not _font:
		_font = load("res://rescourse/object/UI/simsun.ttc")
		var fv = FontVariation.new()
		fv.base_font = _font
		fv.set_spacing(TextServer.SPACING_GLYPH, 1)
		_spaced = fv
	return _spaced
