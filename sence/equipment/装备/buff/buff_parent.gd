extends Node

# 持续时间（秒），子类在 _ready 中写入
# 计时结束后自动 queue_free
var duration: float = 5.0

# 若 >0 则按物理帧计数（代替 duration 的秒数计时）
var frame_duration: int = 0

# 绑定棋子引用，子类用它读写 effect_pool 等
var parent_node: Node

var _timer: Timer
var _frames_left: int = 0


func _ready() -> void:
	if frame_duration > 0:
		_frames_left = frame_duration
		set_physics_process(true)
	else:
		set_physics_process(false)
		_timer = Timer.new()
		_timer.one_shot = true
		_timer.timeout.connect(_on_timeout)
		add_child(_timer)
		_timer.start(duration)


func _physics_process(delta: float) -> void:
	if _frames_left > 0:
		_frames_left -= 1
		if _frames_left <= 0:
			_on_timeout()


func refresh() -> void:
	if frame_duration > 0:
		_frames_left = frame_duration
		set_physics_process(true)
		if _timer:
			_timer.stop()
	else:
		_timer.start(duration)


func _on_timeout() -> void:
	_buff_expired()
	queue_free()


func _buff_expired() -> void:
	pass
