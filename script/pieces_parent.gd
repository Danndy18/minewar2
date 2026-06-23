extends CharacterBody2D

# 全局开关：选中轮廓呼吸灯。可在设置界面切换。
static var breathing_outline_enabled: bool = false

@export var frames: SpriteFrames

# 描边图包：与 frames 对应的填黑版本，用于孪生描边精灵
@export var outline_frames: SpriteFrames

# 装备列表（武器/护甲/头盔/靴子，全往这里塞）
@export var equipment_slots: Array[PackedScene]
# 主动装备列表（盾牌等主动道具）
@export var active_slots: Array[PackedScene]
# AI 模块列表（保存时直接写数组，_ready 里自动组装成容器）
@export var ai_modules: Array[Resource] = []
# 运行时 AI 容器（由 ai_modules 构建，或从外部赋值）
var ai_data: Resource = null

@onready var AnimaUpper = $AnimatedSprite2D_Upper
@onready var AnimaLower = $AnimatedSprite2D_Lower
@onready var select_area = $SelectArea

@onready var attack_area = $AttackArea
@onready var attack_area_shape = $AttackArea/CollisionShape2D

# 攻击判定框的碰撞形状（复用引用，每帧只改 extents）
var attack_area_collision_shape: RectangleShape2D

const SELECTION_MARKER = preload("res://sence/Fight/selection_marker.tscn")
const OUTLINE_BREATHE = preload("res://sence/equipment/特效/outline_breathe.gdshader")
var selection_marker = null

# 阵营系统：0=己方玩家，1=敌方
var camp = 0

# 移动状态：-1=后退，0=停止，1=前进
var is_move: int = 0

# 托管移动状态（非玩家阵营用）：1=自动前进，0=停滞，-1=自动后退
var auto_move: int = 0

# AI 自动技能托管（非玩家阵营用）：true=强制按住S键
var auto_skill: bool = false

# 基础移速（像素/秒）—— 基值，只应在生成时设定，运行时不要动
# 运行时需要改变移速请写入 effect_pool.move_speed（每帧复位）
var move_speed: float = 2000.0

# 当前移速（每帧由效果池算出）
var move_speed_current: float = 2000.0

# ============================================================
# 效果池 —— 容纳每帧可变的修正值
# 池中的键：move_speed（移速修正，乘法）、attack_range（攻击范围修正，乘法）、damage_add（伤害叠加，加法）
# 🚧🚧🚧🚧🚧🚧🚧⚠️注意⚠️🚧🚧🚧🚧🚧🚧🚧
#  所有运行时变动必须走 effect_pool，不能动基础值！ 
#  effect_pool 每帧开头被 _reset_effect_pool() 复位一次， 
#  各系统每帧重新写入自己的修正，互不干扰。
#  基础值（move_speed / health_limit / _taken_base 等）永远只能在生成时设定一次，运行时不要动！不要动！
# ============================================================
var effect_pool: Dictionary = {
	move_speed = 1.0,
	attack_range = 1.0,
	damage_add = 0,
	attack_speed = 1.0,
	damage_taken = 1.0,
	knockback_threshold_mult = 1.0,
	impact_threshold_mult = 1.0,
}

var walk_frame: float = 0.0

# 邻近敌人列表（通过 proximity Area2D 检测）
# 当敌对单位的 proximity 区域重叠时，阻止向前移动
var _nearby_enemies: Dictionary = {}

var unit_id: int
static var _next_id: int = 1
var _tier: int = 0

var health_current: float = 1.0

# ★ 基值 —— 只应在生成时设定，运行时不要动（包括不要直接写 health_limit）
var health_limit: float = 1.0

# ★ 基值 —— 只应在生成时设定，运行时不要动
# 击退阈值（占血量上限的百分比）
var knockback_threshold: float = 0.5
var impact_threshold: float = 0.33

# ★ 基值 —— 只应在生成时设定，运行时不要动
var knockback_pixels: float = 12000.0
var knockback_duration: float = 0.33
var _kb_timer: Timer
var _knockback_speed: float = 0.0
var _knockback_accumulated: float = 0.0
var _pending_damage: int = 0
var _stun_frames_left: int = 0
var _kb_invincible_frames: int = 0
var _stagger_frames: int = 0  # 小击退减速帧计数
var _kb_vertical_speed: float = 0.0
var _kb_origin_y: float = 0.0
var _bounce_vertical_speed: float = 0.0
var _bounce_origin_y: float = 0.0
var _dying: bool = false
var _death_pending: int = 0
var _death_frame: int = 0
var _death_sprites: Array = []  # [sprite, orig_pos] 死亡旋转的子节点列表
var _visual_bounce_enabled: bool = true
var _helmet_armor: Node = null

var damage: int = 0
var frameEnd = 5

# ★ 基值 —— 只应在生成时设定，运行时不要动
var attack_range: float = 12.0

# 当前攻击范围（每帧 = attack_range × effect_pool.attack_range）
var attack_range_current: float = 20.0

# ============================================================
# 装备系统
# ============================================================

# 武器存在标志（加载时由装备设置，用于切换持物/空手动画）
var _has_weapon: bool = false

# 攻击动画参数包（由武器节点在触发攻击时写入）
# _attack_anim_type：动画类型（"轻攻击"/"重攻击"等，拼接前摇/生效区间/后摇）
# 三段各有独立的时间倍率（乘 base_duration）和移速修正（入池）
var _attack_anim_type: String = ""
var _attack_windup_speed: float = 1.0
var _attack_process_speed: float = 1.0
var _attack_recovery_speed: float = 1.0
var _attack_windup_move: float = 1.0
var _attack_process_move: float = 1.0
var _attack_recovery_move: float = 1.0

# 装备实例（挂在子节点下，用于获取子场景的引用）
# 主动物品引用（用于 S 键切换 + 伤害转发）
var _active_item: Node = null
# 主动装备切换脉冲：>0 表示需要切换姿态，每帧-1
# 玩家按S设1（按键帧），AI模拟按S设2（模拟手指按了两帧）
var _s_prev: bool = false  # S键上一帧状态（用于检测松开瞬间）
var active_item_held: bool = false  # S键实时状态：按下=true，松开=false
var shield_raising: bool = false
var _hitbox: Area2D = null

# ★ 基值 —— 只应在生成时设定，运行时不要动
# 护甲数据（由装备的 apply_to 写入生成时）
var _taken_base: float = 1.0
var _armor_speed_penalty: float = 1.0
var _knockback_threshold_mult_base: float = 1.0
var _impact_threshold_mult_base: float = 1.0
# 子类可设此字典覆盖上半身动画条目，key=原动画名, value=替换动画名
# 如僵尸: {"上半身-站立-空手": "上半身-抬手", "上半身-行走": "上半身-抬手"}
var _anim_overrides: Dictionary = {}
# 子类可设此字典覆盖攻击阶段动画，key=阶段名, value=[动画名, 是否倒播]
# 如僵尸: {"前摇": ["上半身-抬手-挥舞", false], "生效区间": ["上半身-抬手-挥舞", true], "后摇": ["上半身-抬手", false]}
var _attack_anim_overrides: Dictionary = {}
# 进食动画帧（食物每帧写入，行走/站立代码之后重播）
var _eating_frame: int = 0
var _eating_active: bool = false
# 通用上半身动画覆盖（弩等主动道具使用）
var _override_upper_anim: String = ""
var _override_upper_frame: int = 0
# 主动道具请求阻断近战攻击（弩瞄准/发射/装填时）
var _block_attack: bool = false
var _equipment_nodes: Array[Node] = []
# buff 系统：轻量字典数组，process_buffs() 在池消费前处理
var _active_buffs: Array[Dictionary] = []
# 受击后仰旋转逐帧动画
var _recoil_frame: int = -1
var _recoil_table: Array = [
	0.0, -8.0, -15.0, -20.0,
	-20.0, -20.0, -20.0, -20.0, -20.0, -20.0, -20.0, -20.0, -20.0,
	-18.0, -15.0, -11.0, -7.0, -3.0, 0.0
]
# 描边孪生精灵系统 — 统一最底层
var _outline_layer: Node2D
var _outline_map: Dictionary = {}  # main_sprite → outline_sprite
var _outline_base: Dictionary = {}  # main_sprite → pieces_parent局部坐标基值
var _breathe_progress: float = 0.0
var _breathe_dir: float = 1.0


# ============================================================
# AI 决策系统变量
# ============================================================

# _ai_decision_cooldown：AI 决策冷却帧数
# 模拟人类反应延迟（20-100 帧），防止 AI 每帧都决策显得"无懈可击"
# 冷却归零时触发一次 _process_ai()，然后重新随机设定
var _ai_decision_cooldown: int = 30

# 强制一轮决策中不再进食的剩余决策轮数（吃完食物后设，每轮-1）
var _eat_cooldown: int = 0

# 下作手段是否已触发（永久关闭）
var _dirty_trick_used: bool = false

# _ai_last_move：上一次 AI 的移动决策
# 用来判断"战术是否切换了"——如果变了，需要插入过渡帧缓冲
var _ai_last_move: int = 1

# _ai_transition：战术切换缓冲计数器
# 当 AI 的决策发生变化时（从前进变后退等），不立刻执行，
# 而是停 5-10 帧（模拟人类需要反应时间来切换操作方向）
# 倒计时在主循环 _process() 中每帧递减
var _ai_transition: int = 0

signal shield_broken
signal active_item_triggered

# ============================================================
# 攻击阶段系统
# 一个完整的攻击周期：随机延迟 → 前摇 → 生效区间 → 后摇 → 闲置
# PRE_WINDUP：加入 0-7 帧随机延迟，打散多人同时攻击
# ============================================================

enum AttackState { IDLE, PRE_WINDUP, WINDUP, PROCESS, RECOVERY }

# 当前所处的攻击阶段
var attack_state: int = AttackState.IDLE

# 当前阶段已持续的帧数（物理帧）
var attack_state_frame: int = 0

# PRE_WINDUP 需要等待的随机帧数（0-7）
var _attack_delay_frames: int = 0

# 角色三段攻击基础帧数（骑手，倍率从 effect_pool 读）
var attack_base_windup: int = 20
var attack_base_process: int = 20
var attack_base_recovery: int = 20

# 攻击待开始标记 — 物理帧信号触发时设 true，_process 跑完 sync 后消费
# 确保武器在攻击状态机启动前已经把参数写进来了
var _attack_pending: bool = false

# 攻击效果帧计数器：攻击开始后每帧+1，到达阈值时武器生成一次效果
var _attack_effect_counter: int = 0
# 本周期是否已经放过效果了（防止阈值反复触发）
var _attack_effect_fired: bool = false



# ============================================================
# 选中系统
# ============================================================

static var selected_node = null
static var selected_nodes: Array[Node] = []
var is_selected := false
var _prev_selected := false

# 全局点击候选：同一帧内只选中 z_index 最高的重叠棋子
static var _click_candidates: Array[Node] = []
static var _click_frame_id: int = -1
static var _has_pending_click: bool = false

# 模板 ID —— 由生成的 .tscn 通过 @export 赋值（子脚本 .gd 也有同名常量作为烙印）
@export var template_id: int = 0

# 每个棋子的永久唯一 ID（时间戳+随机数，运行时绝不碰撞）
var soldier_id: int = 0


func _ready() -> void:
	unit_id = _next_id
	_next_id += 1
	soldier_id = Time.get_ticks_msec() + randi()

	if frames:
		AnimaUpper.sprite_frames = frames
		AnimaLower.sprite_frames = frames
		AnimaUpper.texture_filter = TEXTURE_FILTER_NEAREST
		AnimaLower.texture_filter = TEXTURE_FILTER_NEAREST
		AnimaLower.animation = "下半身-停滞"
		AnimaLower.frame = 0
		AnimaUpper.position.y += 1
		AnimaLower.position.y += 1

	selection_marker = SELECTION_MARKER.instantiate()
	selection_marker.visible = false
	add_child(selection_marker)

	select_area.input_event.connect(_on_select_area_clicked)

	for item in equipment_slots:
		var inst = item.instantiate()
		add_child(inst)
		inst.apply_to(self)
		_equipment_nodes.append(inst)
		var ss: AnimatedSprite2D = inst.get_node_or_null("ShieldSprite")
		if ss:
			_active_item = inst
			_active_item.z_as_relative = false
			if not shield_broken.is_connected(_restore_collision):
				shield_broken.connect(_restore_collision)

	for item in active_slots:
		var inst = item.instantiate()
		add_child(inst)
		inst.apply_to(self)
		_equipment_nodes.append(inst)
		_active_item = inst
		_active_item.z_as_relative = false
		var ss: AnimatedSprite2D = inst.get_node_or_null("ShieldSprite")
		if ss:
			if not shield_broken.is_connected(_restore_collision):
				shield_broken.connect(_restore_collision)

	# 统一偏移所有装备精灵 +1px
	for e in _equipment_nodes:
		for spr in e.get_equipment_sprites():
			spr.position.y += 1

	# 盾牌（主动物品）移到子节点末尾，画在最上层
	if _active_item:
		move_child(_active_item, get_child_count() - 1)

	# 从 ai_modules 自动构建 ai_data 容器
	if ai_data == null and ai_modules.size() > 0:
		var AIContainer = preload("res://sence/equipment/ai/ai父对象/ai_container.gd")
		var container = AIContainer.new()
		container.modules = ai_modules
		ai_data = container

	# 敌对方水平镜像反转（精灵+攻击框整体翻转向左）
	if camp != 0:
		scale.x *= -1

	# 随机偏移防止完全重叠（横±6px）
	position.x += randf_range(-6.0, 6.0)
	# z_index = 层级赋予（Y 越小越靠后，3档）
	z_index = 3 + _tier * 3

	# 同阵营不碰撞：camp 0 → 层1, 其他 → 层2；掩码只勾对方
	# 暂时关闭角色自带的物理碰撞（CharacterBody2D），仅靠 Area2D 系统
	collision_layer = 0
	collision_mask = 0
	#if camp == 0:
	#	collision_layer = 1
	#	collision_mask = 2
	#else:
	#	collision_layer = 2
	#	collision_mask = 1

	# 创建受击框（HitBox），独立于碰撞箱的专用层 3
	var HITBOX_SCRIPT = preload("res://sence/equipment/ai/ai父对象/hitbox_area.gd")
	_hitbox = Area2D.new()
	_hitbox.set_script(HITBOX_SCRIPT)
	_hitbox.collision_layer = 4
	_hitbox.collision_mask = 0
	_hitbox.camp = camp
	_hitbox.parent_node = self
	_hitbox.name = "HitBox"
	var hb_shape = CollisionShape2D.new()
	var hb_rect = RectangleShape2D.new()
	hb_rect.size = Vector2(18, 14)
	hb_shape.shape = hb_rect
	hb_shape.position = Vector2(0, 3)
	hb_shape.debug_color = Color(0, 1, 0, 0.2)
	_hitbox.add_child(hb_shape)
	add_child(_hitbox)

	# 邻近检测 Area2D：比碰撞箱大 0.3px，检测敌对阵营棋子
	# 用于阻止 AI 棋子撞人时反复切换 is_move 导致动画抽搐
	var _proximity_area = Area2D.new()
	_proximity_area.collision_layer = 128
	_proximity_area.collision_mask = 128
	_proximity_area.set_meta("camp", camp)
	_proximity_area.area_entered.connect(_on_proximity_area_entered)
	_proximity_area.area_exited.connect(_on_proximity_area_exited)
	var prox_shape = CollisionShape2D.new()
	var prox_rect = RectangleShape2D.new()
	prox_rect.size = Vector2(18.6, 20.6)
	prox_shape.shape = prox_rect
	prox_shape.position = Vector2(0, 6)
	_proximity_area.add_child(prox_shape)
	add_child(_proximity_area)

	add_to_group("pieces")

	# 攻击/选择 Area2D 覆盖所有阵营层，保证跨阵营检测正常
	attack_area.collision_mask = 4
	select_area.collision_mask = 1 | 2

	# 攻击判定框根据（装备可能修改后的）attack_range 初始化
	attack_area_collision_shape = RectangleShape2D.new()
	attack_area_collision_shape.extents = Vector2(attack_range * 0.5, 8.0)
	attack_area_shape.position = Vector2(attack_range * 0.5, 3.33)
	attack_area_shape.shape = attack_area_collision_shape
	attack_area_shape.debug_color = Color(1, 0.65, 0, 0.2)
	attack_area.area_entered.connect(_on_attack_area_area_entered)

	_kb_timer = Timer.new()
	_kb_timer.one_shot = true
	_kb_timer.timeout.connect(_on_kb_timer_timeout)
	add_child(_kb_timer)

	queue_redraw()
	_kb_origin_y = global_position.y
	_bounce_origin_y = global_position.y

	_setup_outline_system()




func _physics_process(delta: float) -> void:
	_process_pending_damage()

	# 复位 → 各系统向池中写入
	_reset_effect_pool()
	_block_attack = false

	# [池] 盾牌修正：举盾 ×0.5 移速，承伤 ×0（全部乘法入池，不碰基础值）
	if _active_item and shield_raising:
		effect_pool.move_speed *= 0.5          # [池]
		effect_pool.damage_taken *= 0.0        # [池]
	elif _active_item:
		effect_pool.move_speed *= 0.9          # [池]

	# [池] 击退无敌帧：前 10 帧承伤 ×0
	if _kb_invincible_frames > 0:
		_kb_invincible_frames -= 1
		effect_pool.damage_taken *= 0.0        # [池]

	# [池] 小击退减速：8 帧内移速 ×0.25
	if _stagger_frames > 0:
		_stagger_frames -= 1
		effect_pool.move_speed *= 0.25         # [池]

	# [池] 击退中移速 ×0.25
	if _kb_timer.time_left > 0:
		effect_pool.move_speed *= 0.25         # [池]

	# [池] 武器攻击阶段移速/攻速修正（每帧按当前阶段乘法入池）
	if attack_state >= 1 and attack_state <= 3:
		match attack_state:
			AttackState.WINDUP:
				effect_pool.move_speed *= _attack_windup_move     # [池]
				effect_pool.attack_speed *= _attack_windup_speed   # [池]
			AttackState.PROCESS:
				effect_pool.move_speed *= _attack_process_move     # [池]
				effect_pool.attack_speed *= _attack_process_speed   # [池]
			AttackState.RECOVERY:
				effect_pool.move_speed *= _attack_recovery_move    # [池]
				effect_pool.attack_speed *= _attack_recovery_speed  # [池]

	# 待攻击标记消费：放在 sync 之前，这样武器 sync() 时就能看到 state=1 并写入参数
	if _attack_pending and not _block_attack:
		_attack_pending = false
		_attack_effect_counter = 0
		_attack_effect_fired = false
		attack_state = AttackState.PRE_WINDUP
		attack_state_frame = 0

	# buff 系统处理（在池消费前生效，各装备 sync 可以读 _active_buffs）
	_process_buffs()

	# 装备同步（池写入/贴图/动画/帧）—— 放在读池前，让 armor 减速修正赶本帧消费
	for e in _equipment_nodes:
		if is_instance_valid(e):
			e.sync(self)

	# [读] 所有修正已写入，读池消费
	move_speed_current = move_speed * effect_pool.move_speed
	attack_range_current = attack_range * effect_pool.attack_range

	# 后退减速（阻止频繁拉扯，阵营不同撤退方向也不同）
	var retreat_dir = -1 if camp == 0 else 1
	if is_move == retreat_dir:
		move_speed_current *= 0.6

	# 攻击判定框同步到当前范围
	attack_area_collision_shape.extents = Vector2(attack_range_current * 0.5, 8.0)
	attack_area_shape.position = Vector2(attack_range_current * 0.5, 10.0)

	# 击退（±2）→ 专用函数处理，跳过常规移动逻辑
	if abs(is_move) == 2:
		_process_knockback(delta, retreat_dir)
	else:
		_kb_vertical_speed = 0.0
		velocity = Vector2(is_move, 0) * move_speed_current * delta
		if _bounce_vertical_speed != 0.0:
			velocity.y = _bounce_vertical_speed * delta
		_bounce_vertical_speed += 1000.0
		move_and_slide()
		# 落回原位后强制归位并停止弹跳
		if _bounce_vertical_speed > 0 and global_position.y >= _bounce_origin_y:
			global_position.y = _bounce_origin_y
			_bounce_vertical_speed = 0.0

	# ============================================================
	# 行走动画（用实时的 is_move 而不是提前捕获）
	# ============================================================
	var is_walking_now = abs(is_move) == 1

	# 行走帧计数器
	if is_walking_now:
		walk_frame += is_move * (move_speed_current / 15000.0)
		walk_frame = fmod(walk_frame, 6.0)
		if walk_frame < 0.0:
			walk_frame += 6.0
	else:
		walk_frame = 0.0

	# 下半身手动帧
	if is_walking_now:
		AnimaLower.animation = "下半身-行走"
		AnimaLower.frame = int(walk_frame)
	else:
		AnimaLower.animation = "下半身-停滞"
		AnimaLower.frame = 0

	# 上半身优先级控制
	if shield_raising:
		_set_upper("上半身-抬手")
		AnimaUpper.frame = 0
	elif attack_state != AttackState.IDLE:
		attack_state_frame += 1

		# 效果计数器：物理帧计数，到达前摇阈值时通知武器生成效果
		_attack_effect_counter += 1
		if not _attack_effect_fired:
			var _effect_threshold = attack_base_windup * _attack_windup_speed
			if _attack_effect_counter >= _effect_threshold:
				_attack_effect_fired = true
				for e in _equipment_nodes:
					if is_instance_valid(e) and e.has_method("spawn_effect"):
						e.spawn_effect(self)

		match attack_state:
			AttackState.PRE_WINDUP:
				if attack_state_frame >= _attack_delay_frames:
					attack_state = AttackState.WINDUP
					attack_state_frame = 0
			AttackState.WINDUP:
				var _w_entry = _attack_anim_overrides.get("前摇")
				var _w_anim = _w_entry[0] if _w_entry else "上半身-" + _attack_anim_type + "-前摇"
				var _w_reverse = _w_entry[1] if _w_entry else false
				var _w_dur = attack_base_windup * _attack_windup_speed
				_set_upper_attack_frame(_w_anim, _w_dur, _w_reverse)
				if attack_state_frame >= _w_dur:
					attack_state = AttackState.PROCESS
					attack_state_frame = 0
			AttackState.PROCESS:
				var _p_entry = _attack_anim_overrides.get("生效区间")
				var _p_anim = _p_entry[0] if _p_entry else "上半身-" + _attack_anim_type + "-生效区间"
				var _p_reverse = _p_entry[1] if _p_entry else false
				var _p_dur = attack_base_process * _attack_process_speed
				_set_upper_attack_frame(_p_anim, _p_dur, _p_reverse)
				if attack_state_frame >= _p_dur:
					attack_state = AttackState.RECOVERY
					attack_state_frame = 0
			AttackState.RECOVERY:
				var _r_entry = _attack_anim_overrides.get("后摇")
				var _r_anim = _r_entry[0] if _r_entry else "上半身-" + _attack_anim_type + "-后摇"
				var _r_reverse = _r_entry[1] if _r_entry else false
				var _r_dur = attack_base_recovery * _attack_recovery_speed
				_set_upper_attack_frame(_r_anim, _r_dur, _r_reverse)
				if attack_state_frame >= _r_dur:
					attack_state = AttackState.IDLE
					attack_state_frame = 0
					_attack_effect_counter = 0
					_attack_effect_fired = false
					# 攻击结束，检查范围内是否还有敌人，有则标记待续接
					if attack_area.monitoring:
						for b in attack_area.get_overlapping_areas():
							var c = b.get("camp")
							if c != null and c != camp:
								_attack_delay_frames = randi() % 8
								_attack_pending = true
								break
	elif is_walking_now:
		_set_upper("上半身-行走")
		AnimaUpper.frame = int(walk_frame) if not _anim_overrides.has("上半身-行走") else 0
	else:
		if _has_weapon:
			_set_upper("上半身-站立-持物")
			AnimaUpper.frame = 0
		else:
			_set_upper("上半身-站立-空手")
			AnimaUpper.frame = 0

	# 进食动画覆盖（走在行走/站立后面，保证优先级）
	if _eating_active:
		AnimaUpper.animation = _anim_overrides.get("上半身-单手抬手-挥舞", "上半身-单手抬手-挥舞")
		AnimaUpper.frame = _eating_frame

	# 通用主动道具动画覆盖（弩等）
	if _override_upper_anim != "":
		AnimaUpper.animation = _anim_overrides.get(_override_upper_anim, _override_upper_anim)
		AnimaUpper.frame = _override_upper_frame

	# 空闲时每帧检测攻击区域是否有敌人
	if not _dying and not _attack_pending and not _block_attack and _stun_frames_left <= 0 and _kb_timer.time_left <= 0 and attack_state == AttackState.IDLE and attack_area.monitoring:
		for area in attack_area.get_overlapping_areas():
			var c = area.get("camp")
			if c != null and c != camp:
				_attack_delay_frames = randi() % 8
				_attack_pending = true
				break

	# 击退：双阈值逐帧检查（health_limit 可能浮动）
	if _knockback_accumulated >= health_limit * knockback_threshold * effect_pool.knockback_threshold_mult:
		_start_knockback()

	if health_current <= 0 and not _dying:
		_dying = true
		_death_pending = 2

	# 死亡延迟计数（等 _deferred_reparent 先跑完）
	if _death_pending > 0:
		_death_pending -= 1
		if _death_pending == 0:
			die()

	if _death_frame == 0 and _recoil_frame >= 0:
		if _recoil_frame < _recoil_table.size():
			var rot = deg_to_rad(_recoil_table[_recoil_frame])
			AnimaUpper.rotation = rot
			AnimaLower.rotation = rot
			_recoil_frame += 1
		else:
			_recoil_frame = -1
			AnimaUpper.rotation = 0.0
			AnimaLower.rotation = 0.0

	if _stun_frames_left > 0:
		_stun_frames_left -= 1

	if _death_frame > 0:
		_death_frame += 1
		if _death_frame <= 20:
			var angle = deg_to_rad(-90.0 * _death_frame / 20.0)
			var foot = Vector2(0, 15)
			for pair in _death_sprites:
				var spr = pair[0]
				var offset = pair[1]
				if is_instance_valid(spr):
					var target_pp = foot + offset.rotated(angle)
					spr.global_position = to_global(target_pp)
					spr.rotation = angle
		modulate = Color(1.0, 1.0 - minf(_death_frame / 20.0, 1.0) * 0.7, 1.0 - minf(_death_frame / 20.0, 1.0) * 0.7, 1.0)
		if _death_frame == 30:
			deselect()
			var smoke = Node2D.new()
			smoke.set_script(load("res://sence/equipment/特效/smoke_particles.gd"))
			smoke.global_position = global_position + Vector2(-30 if camp == 0 else 30, 40)
			get_tree().root.add_child(smoke)
			queue_free()


func _process(delta: float) -> void:
	# 全局点击解析：从候选列表中选 z_index 最高的棋子
	if _has_pending_click:
		_has_pending_click = false
		if not _click_candidates.is_empty():
			var top = _click_candidates[0]
			var top_z = top.z_index
			for p in _click_candidates:
				if p.z_index > top_z:
					top_z = p.z_index
					top = p
			deselect_all()
			top.select()

	# 装备描边同步
	_sync_outline_sprites()

	if camp == 0 and is_selected and not _prev_selected:
		flash_white()
	_prev_selected = is_selected

	# 选中呼吸灯：轮廓渐变色 #d08100 循环 0→1→0
	if breathing_outline_enabled:
		if is_selected:
			_breathe_progress += _breathe_dir * 0.01
			if _breathe_progress >= 1.0:
				_breathe_progress = 1.0
				_breathe_dir = -1.0
			elif _breathe_progress <= 0.0:
				_breathe_progress = 0.0
				_breathe_dir = 1.0
			for ol in _outline_map.values():
				if ol.material:
					ol.material.set_shader_parameter("breathe", _breathe_progress)
		else:
			_breathe_progress = maxf(0.0, _breathe_progress - 0.05)
			_breathe_dir = 1.0
			for ol in _outline_map.values():
				if ol.material:
					ol.material.set_shader_parameter("breathe", _breathe_progress)

	# ============================================================
	# AI 决策循环（非玩家棋子）
	#
	# 核心机制（模拟人类操作，防止 AI 反应过快）：
	#
	#   1. 决策冷却（20-100 帧）
	#      每帧不决策，避免"无懈可击"感。不同棋子的冷却随机，
	#      同一阵营的 AI 不会同时变换战术，更像真实人类。
	#
	#   2. 战术切换缓冲（5-10 帧）
	#      当 AI 新决策与上次不同时，插入 5-10 帧的 is_move=0，
	#      模拟人类"松开按键 → 思考 → 按新方向键"的延迟。
	#
	#   3. 初始进场延迟（30 帧）
	#      _ai_decision_cooldown 初始值为 30，让棋子先走几步
	#      再开始 AI 判断，不会一出生就原地站着"想"。
	#
	#   4. 无 AI 时默认冲锋
	#      如果 ai_data 为空（null），不启动决策系统，
	#      直接 auto_move=1 无脑往前走。
	# ============================================================
	if camp != 0:
		if ai_data:
			if _ai_decision_cooldown <= 0:
				var ai_cooldown = _process_ai()
				_ai_decision_cooldown = ai_cooldown if ai_cooldown != null else int(20 + pow(randf(), 2) * 80)
			else:
				_ai_decision_cooldown -= 1
			# 切换缓冲每帧递减（不卡在决策周期里）
			if _ai_transition > 0:
				_ai_transition -= 1
				auto_move = 0
		else:
			auto_move = 1

	queue_redraw()

	# ============================================================
	# 移动控制
	# 玩家阵营（camp==0）：选中时键盘控制或 Shift+方向键发布托管指令
	# 非玩家阵营（camp!=0）：由 auto_move 托管
	#   auto_move=1 → 自动前进（朝面朝方向，镜像阵营自动反向）
	#   auto_move=0 → 停滞
	#   auto_move=-1 → 自动后退
	# ============================================================
	# 击退（is_move == ±2）或硬直时跳过移动输入
	if abs(is_move) != 2 and _stun_frames_left <= 0:
		if camp == 0:
			if is_selected:
				active_item_held = Input.is_key_pressed(KEY_S) and attack_state == AttackState.IDLE and not _dying
				_s_prev = active_item_held
				if Input.is_key_pressed(KEY_SHIFT):
					if Input.is_action_pressed("move_right"):
						auto_move = 1
						deselect()
						return
					elif Input.is_action_pressed("move_left"):
						auto_move = -1
						deselect()
						return
					return
				is_move = 0
				if Input.is_action_pressed("move_left"):
					is_move = -1
				elif Input.is_action_pressed("move_right"):
					is_move = 1
			else:
				is_move = auto_move
		else:
			is_move = auto_move * -1
			if auto_skill and attack_state == AttackState.IDLE and not _dying:
				active_item_held = true
			else:
				active_item_held = false

		# 靠近敌人时禁止向前移动（人控和 AI 都生效）
		if not _nearby_enemies.is_empty():
			if camp == 0 and is_move == 1:
				is_move = 0
			elif camp == 1 and is_move == -1:
				is_move = 0

	queue_redraw()

func _process_pending_damage():
	if _pending_damage <= 0:
		return
	var amount = _pending_damage * effect_pool.damage_taken
	_pending_damage = 0
	if amount <= 0.0:
		return
	amount = maxf(1.0, amount)

	# 击退/后仰效果（扣血之前，头盔保护也能触发）
	if _kb_timer.time_left <= 0:
		_knockback_accumulated += amount
		if amount >= health_limit * impact_threshold * effect_pool.impact_threshold_mult:
			_start_knockback()
		elif _knockback_accumulated >= health_limit * knockback_threshold * effect_pool.knockback_threshold_mult:
			_start_knockback()
		elif amount >= 2.5:
			_visual_hit_bounce()
			_stagger_frames = 8
		elif amount >= 0.5:
			pass

	# 倒数第二：头盔保护 — 有头盔且冲击击退时让头盔处理，跳过扣血
	if _helmet_armor != null and amount >= health_limit * impact_threshold * effect_pool.impact_threshold_mult:
		_helmet_armor.on_helmet_blocked(self)
		return

	# 倒数第一：扣血
	health_current -= amount

	# 扣血之后才闪红（头盔拦截的不闪）
	flash_red(0.2, 0.5) if amount < 2.5 else flash_red()


func take_damage(amount: int, attacker_weapon_type: String = "", counter_shield: bool = false):
	if health_current <= 0:
		return
	_pending_damage += amount


func _start_knockback(do_flash: bool = true):
	if _kb_timer.time_left > 0:
		return
	_knockback_accumulated = 0
	_knockback_speed = knockback_pixels
	_kb_vertical_speed = -8000.0
	_bounce_vertical_speed = 0.0
	_recoil_frame = 0
	attack_state = AttackState.IDLE
	attack_state_frame = 0
	_attack_pending = false
	_attack_effect_counter = 0
	_attack_effect_fired = false
	is_move = -2 if camp == 0 else 2
	_kb_invincible_frames = 10
	_kb_timer.start(knockback_duration)


func _restore_collision():
	if _hitbox:
		_hitbox.monitoring = true
		_hitbox.collision_layer = 4
	_active_item = null
	shield_raising = false
	if not _dying:
		_start_knockback(false)


func _on_kb_timer_timeout():
	is_move = 0
	_stun_frames_left = 20
	global_position.y = _kb_origin_y


func _setup_outline_system():
	_outline_layer = Node2D.new()
	_outline_layer.name = "OutlineLayer"
	add_child(_outline_layer)
	move_child(_outline_layer, 0)

	for pair in _collect_outline_items():
		var main = pair[0] as AnimatedSprite2D
		var of = pair[1] as SpriteFrames
		if not of or not is_instance_valid(main):
			continue
		var base = main.position if main.get_parent() == self else to_local(main.global_position)
		var ol = AnimatedSprite2D.new()
		ol.sprite_frames = of
		ol.animation = main.animation
		ol.frame = main.frame
		ol.scale = main.scale
		ol.position = base
		ol.modulate = Color.BLACK
		ol.texture_filter = TEXTURE_FILTER_NEAREST
		ol.material = ShaderMaterial.new()
		ol.material.shader = OUTLINE_BREATHE
		_outline_layer.add_child(ol)
		_outline_map[main] = ol
		_outline_base[main] = base


func _collect_outline_items() -> Array:
	var result: Array = []
	if outline_frames:
		result.append([AnimaUpper, outline_frames])
		result.append([AnimaLower, outline_frames])
	for e in _equipment_nodes:
		if is_instance_valid(e):
			for pair in e.get_outline_pairs():
				result.append(pair)
	return result


func _sync_outline_sprites():
	for main in _outline_map.keys().duplicate():
		var ol = _outline_map.get(main)
		if not is_instance_valid(main) or not is_instance_valid(ol):
			if is_instance_valid(ol):
				ol.queue_free()
			_outline_map.erase(main)
			_outline_base.erase(main)
			continue
		ol.animation = main.animation
		ol.frame = main.frame
		ol.rotation = main.rotation
		ol.offset = main.offset
		ol.scale = main.scale
		ol.visible = main.visible
		if main.sprite_frames == null:
			ol.sprite_frames = null
		if not _dying:
			var cur = main.position if main.get_parent() == self else to_local(main.global_position)
			ol.position = cur


func die():
	_dying = true
	collision_layer = 0
	collision_mask = 0
	attack_area.monitoring = false
	if _kb_timer.time_left > 0:
		_kb_timer.stop()
	is_move = 0
	velocity = Vector2.ZERO
	_knockback_speed = 0.0
	_kb_vertical_speed = 0.0
	_bounce_vertical_speed = 0.0
	_death_frame = 1

	# 收集所有需要旋转的子节点（绕脚底+1），统一转成 pieces_parent 局部坐标
	_death_sprites.clear()
	var foot = Vector2(0, 15)
	for spr in [AnimaUpper, AnimaLower]:
		if is_instance_valid(spr):
			_death_sprites.append([spr, to_local(spr.global_position) - foot])
	for e in _equipment_nodes:
		for spr in e.get_equipment_sprites():
			if is_instance_valid(spr):
				_death_sprites.append([spr, to_local(spr.global_position) - foot])
	for pair in _outline_map:
		var ol = _outline_map[pair]
		if is_instance_valid(ol):
			_death_sprites.append([ol, to_local(ol.global_position) - foot])

	# 清理插在身上的箭矢（deferred_reparent 已经执行完毕）
	for proj in get_tree().get_nodes_in_group("stuck_projectiles"):
		if is_instance_valid(proj) and proj.get_parent() == self:
			proj.queue_free()


func _process_knockback(delta: float, retreat_dir: int):
	var _move_dir = retreat_dir
	move_speed_current = _knockback_speed
	_knockback_speed = maxf(_knockback_speed - 90.0, 0.0)

	velocity = Vector2(_move_dir, 0) * move_speed_current * delta
	if _kb_vertical_speed != 0.0:
		velocity.y = _kb_vertical_speed * delta
	_kb_vertical_speed += 1000.0

	move_and_slide()

	if _kb_vertical_speed > 0 and global_position.y >= _kb_origin_y:
		_kb_vertical_speed = 0.0


func _on_proximity_area_entered(area: Area2D) -> void:
	if area.has_meta("camp") and area.get_meta("camp") != camp:
		_nearby_enemies[area] = true

func _on_proximity_area_exited(area: Area2D) -> void:
	_nearby_enemies.erase(area)


func _on_attack_area_area_entered(area: Area2D) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _stun_frames_left > 0 or _kb_timer.time_left > 0:
		return
	if _block_attack:
		return
	var target_camp = area.get("camp")
	if target_camp != null and target_camp != camp:
		_attack_delay_frames = randi() % 8
		_attack_pending = true


# ============================================================
# buff 系统：增/删/处理
# ============================================================

func add_buff(id: String, frames: int, extra: Dictionary = {}) -> void:
	for b in _active_buffs:
		if b.id == id:
			if b.frames < frames:
				b.frames = frames
			for k in extra:
				b[k] = extra[k]
			return
	var entry = extra.duplicate()
	entry.id = id
	entry.frames = frames
	_active_buffs.append(entry)


func remove_buff(id: String) -> void:
	for i in range(_active_buffs.size() - 1, -1, -1):
		if _active_buffs[i].id == id:
			_active_buffs.remove_at(i)


func _process_buffs() -> void:
	var i = 0
	while i < _active_buffs.size():
		var b = _active_buffs[i]
		b.frames -= 1

		if b.id == "saturation":
			health_current = minf(health_current + b.get("heal", 0.0), health_limit)
			effect_pool.move_speed *= b.get("speed", 1.0)
			if walk_frame != 0.0:
				b.frames -= 1

		if b.frames <= 0:
			_active_buffs.remove_at(i)
		else:
			i += 1


# ============================================================
# _set_upper(anim_name) — 唯一设上半身动画的入口
# 检查 _anim_overrides，有映射就替换，没有就用原值
# 动作树今后随便加，这里只有一个赋值点
# ============================================================
func _set_upper(anim_name: String) -> void:
	AnimaUpper.animation = _anim_overrides.get(anim_name, anim_name)


# ============================================================
# _set_upper_attack_frame(anim_name, stage_duration)
# 替代 play()，手动将上半身动画帧映射到阶段时长内
# 例：动画有 3 帧，阶段持续 20 帧 → 每 6.6 帧进一帧15.0
# ============================================================
func _set_upper_attack_frame(anim_name: String, stage_duration: float, reverse: bool = false):
	if not AnimaUpper.sprite_frames.has_animation(anim_name):
		return
	AnimaUpper.animation = anim_name
	var frame_count = AnimaUpper.sprite_frames.get_frame_count(anim_name)
	if frame_count <= 0 or stage_duration <= 0:
		AnimaUpper.frame = 0
		return
	var progress = float(attack_state_frame) / stage_duration
	var raw = int(progress * frame_count)
	AnimaUpper.frame = clampi((frame_count - 1 - raw) if reverse else raw, 0, frame_count - 1)


# ============================================================
# _on_select_area_clicked(viewport, event, shape_idx)
# Area2D 的鼠标点击回调。
# ============================================================
func _on_select_area_clicked(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if camp != 0:
			return
		var frame = Engine.get_process_frames()
		if frame != _click_frame_id:
			_click_frame_id = frame
			_click_candidates.clear()
		_click_candidates.append(self)
		_has_pending_click = true


func select():
	if is_selected:
		return
	is_selected = true
	selected_nodes.append(self)
	selected_node = self
	auto_move = 0  # 选中即取消托管


func deselect():
	if not is_selected:
		return
	is_selected = false
	is_move = 0
	selected_nodes.erase(self)
	if selected_node == self:
		selected_node = selected_nodes.back() if selected_nodes else null


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_W and event.pressed and self == selected_node:
		get_viewport().set_input_as_handled()
		_select_same_template()


func _select_same_template():
	deselect_all()
	var pieces = Engine.get_main_loop().get_nodes_in_group("pieces")
	for p in pieces:
		if is_instance_valid(p) and p.get("template_id") == template_id and p.get("camp") == 0:
			p.select()


func flash_white():
	AnimaUpper.self_modulate = Color(5, 5, 5, 1)
	AnimaLower.self_modulate = Color(5, 5, 5, 1)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(AnimaUpper, "self_modulate", Color(1, 1, 1, 1), 0.2)
	tw.tween_property(AnimaLower, "self_modulate", Color(1, 1, 1, 1), 0.2)


func flash_red(duration: float = 0.1, intensity: float = 1.0):
	AnimaUpper.self_modulate = Color(3.0 * intensity, 0.3, 0.3, 1.0)
	AnimaLower.self_modulate = Color(3.0 * intensity, 0.3, 0.3, 1.0)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(AnimaUpper, "self_modulate", Color(1, 1, 1, 1), duration)
	tw.tween_property(AnimaLower, "self_modulate", Color(1, 1, 1, 1), duration)


func _visual_hit_bounce():
	if not _visual_bounce_enabled:
		return
	_bounce_origin_y = global_position.y
	_bounce_vertical_speed = -4000.0


static func deselect_all():
	for p in selected_nodes.duplicate():
		if is_instance_valid(p):
			p.deselect()


static func box_select(rect: Rect2):
	deselect_all()
	var pieces = Engine.get_main_loop().get_nodes_in_group("pieces")
	for p in pieces:
		if p.get("camp") != 0:
			continue
		if rect.has_point(p.global_position):
			p.select()


# ============================================================
# _process_ai()
# AI 决策主函数 —— 每个冷却周期调用一次（非每帧）
#
# 流程：
#   1. 调用 ai_data.evaluate(self) 获取所有维度的合并决策
#      （如果是组合容器，则内部遍历所有子模块）
#   2. 从结果中提取 move（移动方向）和 shield（举盾/收盾）
#   3. 如果决策与上次不同，启动 5-10 帧的"切换缓冲"
#      （缓冲期间 is_move=0，模拟人类换键的停顿）
#   4. 如果决策没变，直接执行
# ============================================================
func _process_ai():
	if _eat_cooldown > 0:
		_eat_cooldown -= 1

	# 每轮决策重置 auto_skill，模块必须每轮显式设 true 才生效
	auto_skill = false

	# 调用当前 AI 模块/容器的 evaluate()，获取合并后的决策字典
	# {
	#   "move":   1=前进, -1=后退, 0=停止, null=不关心
	#   "shield": true=举盾, false=收盾, null=不关心
	# }
	var result = ai_data.evaluate(self)

	# 提取 move 决策，用于后续切换缓冲判断
	var new_move = result.move

	# AI 盾牌决策：直接设置（不经过按键边缘检测，AI 知道要什么）
	if result.shield != null:
		shield_raising = result.shield

	if result.get("auto_skill") != null:
		auto_skill = result.get("auto_skill")

	# 战术切换缓冲
	# 如果还在缓冲期（_ai_transition > 0），维持 auto_move=0
	# 缓冲由主循环 _process() 每帧递减
	# 注意：进食等高优先级动作需要移动+技能同时生效，跳过缓冲
	if _ai_transition > 0 and not auto_skill:
		auto_move = 0
	else:
		_ai_transition = 0
		# 缓冲已结束
		if new_move != _ai_last_move:
			if auto_skill:
				auto_move = new_move
			else:
				_ai_transition = 5 + randi() % 6
				auto_move = 0
		else:
			auto_move = new_move

	# 记录本次决策，供下一周期比较
	_ai_last_move = new_move
	return result.get("cooldown")


func force_ai_decision() -> void:
	_ai_decision_cooldown = 0


# ============================================================
# _reset_effect_pool()
# 每帧 _physics_process 开头调用一次。
# ★ 效果池复位：各系统之后每帧重新写入自己的修正
# ★ 基础值（_taken_base / _armor_speed_penalty 等）不在此处写入
#   它们只是冲池用的"基准"，但基础值本身永远不应在运行时被修改
# ============================================================
func _reset_effect_pool():
	effect_pool.move_speed = 1.0
	effect_pool.attack_range = 1.0
	effect_pool.damage_add = 0
	effect_pool.attack_speed = 1.0
	effect_pool.damage_taken = _taken_base
	effect_pool.knockback_threshold_mult = _knockback_threshold_mult_base
	effect_pool.impact_threshold_mult = _impact_threshold_mult_base
