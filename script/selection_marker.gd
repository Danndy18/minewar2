extends AnimatedSprite2D

# 选中标记状态机
# HIDDEN    — 完全隐藏
# FADE_IN   — 选入，播放 "in" → SELECTED 播 "base"
# SELECTED  — 常驻循环动画 "base"
# FADE_OUT  — 取消选中且 auto_move=0，播放 "out" 淡出后隐藏
# AUTO_MOVE — 取消选中且 auto_move≠0，播放 "autocome"/"autoback" 后隐藏
enum State { HIDDEN, FADE_IN, SELECTED, FADE_OUT, AUTO_MOVE }
var _state: int = State.HIDDEN
var _prev_selected: bool = false

func _ready() -> void:
	visible = false
	animation_finished.connect(_on_anim_finished)


func _process(delta: float) -> void:
	var p = get_parent()
	if p == null:
		return
	var selected = p.get("is_selected") == true

	# 仅在 is_selected 切换时触发，不做每帧重入判断
	if selected != _prev_selected:
		_prev_selected = selected
		if selected:
			_state = State.FADE_IN
			visible = true
			play("in")
		else:
			var auto = p.get("auto_move")
			if auto == null:
				auto = 0
			match auto:
				1:   # 托管前进
					_state = State.AUTO_MOVE
					visible = true
					play("autocome")
				-1:  # 托管后退
					_state = State.AUTO_MOVE
					visible = true
					play("autoback")
				_:   # 原地等待 → 淡出隐藏
					_state = State.FADE_OUT
					play("out")


func _on_anim_finished():
	match _state:
		State.FADE_IN:
			_state = State.SELECTED
			play("base")
		State.FADE_OUT:
			_state = State.HIDDEN
			visible = false
		State.AUTO_MOVE:
			_state = State.HIDDEN
			visible = false
		State.SELECTED:
			pass
