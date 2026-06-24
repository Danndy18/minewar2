extends Node2D


const ZOMBIE_TEMPLATE = preload("res://sence/Fight/角色样板/僵尸样板.tscn")
const ZOMBIE_HUNGRY = preload("res://sence/Fight/角色样板/饥饿的僵尸.tscn")
const ZOMBIE_CLAW = preload("res://sence/equipment/装备/武器/武器库/僵尸之爪/weapon_template.tscn")
const PREVIEW_SCENE = preload("res://sence/Fight/展示用角色/展示用角色.tscn")
const PiecesParent = preload("res://script/pieces_parent.gd")
const AIContainer = preload("res://sence/equipment/ai/ai父对象/ai_container.gd")

# ========== 装备数据 ==========
const WEAPONS = {
	"拳": "res://sence/equipment/装备/武器/武器库/拳/weapon_template.tscn",
	"木剑": "res://sence/equipment/装备/武器/武器库/剑/剑子类/木剑.tscn",
	"石剑": "res://sence/equipment/装备/武器/武器库/剑/剑子类/石剑.tscn",
	"铁剑": "res://sence/equipment/装备/武器/武器库/剑/剑子类/铁剑.tscn",
	"金剑": "res://sence/equipment/装备/武器/武器库/剑/剑子类/金剑.tscn",
	"钻石剑": "res://sence/equipment/装备/武器/武器库/剑/剑子类/钻石剑.tscn",
	"木斧": "res://sence/equipment/装备/武器/武器库/斧/斧子类/木斧.tscn",
	"石斧": "res://sence/equipment/装备/武器/武器库/斧/斧子类/石斧.tscn",
	"铁斧": "res://sence/equipment/装备/武器/武器库/斧/斧子类/铁斧.tscn",
	"金斧": "res://sence/equipment/装备/武器/武器库/斧/斧子类/金斧.tscn",
	"钻石斧": "res://sence/equipment/装备/武器/武器库/斧/斧子类/钻石斧.tscn",
	"弓": "res://sence/equipment/装备/武器/武器库/弓/weapon_template.tscn",
	"木镐": "res://sence/equipment/装备/武器/武器库/镐/镐子类/木镐.tscn",
	"石镐": "res://sence/equipment/装备/武器/武器库/镐/镐子类/石镐.tscn",
	"铁镐": "res://sence/equipment/装备/武器/武器库/镐/镐子类/铁镐.tscn",
	"金镐": "res://sence/equipment/装备/武器/武器库/镐/镐子类/金镐.tscn",
	"钻石镐": "res://sence/equipment/装备/武器/武器库/镐/镐子类/钻石镐.tscn",
}
const ARMORS = {
	"铁板甲": "res://sence/equipment/装备/护甲/护甲库/板甲/板甲子类/铁板甲.tscn",
	"金板甲": "res://sence/equipment/装备/护甲/护甲库/板甲/板甲子类/金板甲.tscn",
	"钻石板甲": "res://sence/equipment/装备/护甲/护甲库/板甲/板甲子类/钻石板甲.tscn",
	"链甲": "res://sence/equipment/装备/护甲/护甲库/链甲/链甲.tscn",
}
const LEGGINGS = {
	"铁护腿": "res://sence/equipment/装备/护甲/护甲库/护腿/护腿子类/铁护腿.tscn",
	"金护腿": "res://sence/equipment/装备/护甲/护甲库/护腿/护腿子类/金护腿.tscn",
	"钻石护腿": "res://sence/equipment/装备/护甲/护甲库/护腿/护腿子类/钻石护腿.tscn",
	"链护腿": "res://sence/equipment/装备/护甲/护甲库/链甲/链护腿.tscn",
}
const HELMETS = {
	"铁板盔": "res://sence/equipment/装备/护甲/护甲库/板盔/板盔子类/铁板盔.tscn",
	"金板盔": "res://sence/equipment/装备/护甲/护甲库/板盔/板盔子类/金板盔.tscn",
	"钻石板盔": "res://sence/equipment/装备/护甲/护甲库/板盔/板盔子类/钻石板盔.tscn",
	"链盔": "res://sence/equipment/装备/护甲/护甲库/链甲/链盔.tscn",
}
const BOOTS = {
	"铁板靴": "res://sence/equipment/装备/护甲/护甲库/板靴/板靴子类/铁板靴.tscn",
	"金板靴": "res://sence/equipment/装备/护甲/护甲库/板靴/板靴子类/金板靴.tscn",
	"钻石板靴": "res://sence/equipment/装备/护甲/护甲库/板靴/板靴子类/钻石板靴.tscn",
	"链靴": "res://sence/equipment/装备/护甲/护甲库/链甲/链靴.tscn",
}
const ACTIVE_ITEMS = {
	"盾牌": "res://sence/equipment/装备/主动道具/主动装备库/盾牌/shield_template.tscn",
	"食物补给": "res://sence/equipment/装备/主动道具/主动装备库/食物/food_supply.tscn",
	"弩": "res://sence/equipment/装备/主动道具/主动装备库/弩/crossbow_template.tscn",
}
const AI_OPTIONS = {
	"冲锋": "res://sence/equipment/ai/ai模板/ai_charge.tres",
	"游走": "res://sence/equipment/ai/ai模板/ai_hit_and_run.tres",
	"结阵": "res://sence/equipment/ai/ai模板/ai_gang.tres",
	"盾兵": "res://sence/equipment/ai/ai模板/ai_shield.tres",
	"持盾跟随": "res://sence/equipment/ai/ai模板/ai_follow_shield.tres",
	"进食": "res://sence/equipment/ai/ai模板/ai_eat.tres",
	"下作手段": "res://sence/equipment/ai/ai模板/ai_dirty_trick.tres",
}

const PALETTE_COLORS = {
	"木": Color(0.545, 0.369, 0.235),
	"石": Color(0.490, 0.490, 0.490),
	"铁": Color(0.584, 0.584, 0.584),
	"链": Color(0.42, 0.42, 0.42),
	"金": Color(0.976, 0.745, 0.216),
	"钻石": Color(0.2, 0.922, 0.796),
	"拳": Color(0.8, 0.6, 0.4),
	"弓": Color(0.5, 0.3, 0.1),
	"盾牌": Color(0.4, 0.4, 0.6),
	"食物补给": Color(0.6, 0.4, 0.2),
	"弩": Color(0.3, 0.3, 0.5),
}

var _config = {
	"name": "",
	"weapon": null,
	"armor": null,
	"leggings": null,
	"helmet": null,
	"boots": null,
	"active": null,
	"ai": [],
}
var _dragging: bool = false
var _drag_start: Vector2
var _drag_end: Vector2
var _window_layer: CanvasLayer = null
var _test_window: Node = null
var _option_items: Array[String] = []
var _option_clip: Control = null
var _option_content: Control = null
var _scroll_base: TextureRect = null
var _scroll_btn: TextureRect = null


func _ready():
	# 预加载所有装备资源
	for d in [WEAPONS, ARMORS, LEGGINGS, HELMETS, BOOTS, ACTIVE_ITEMS]:
		for p in d.values():
			load(p)

	var cl = $CanvasLayer
	var sw = cl.get_viewport().size.x
	var sh = cl.get_viewport().size.y

	var left_w = 280
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.size = Vector2(left_w, sh)
	bg.position = Vector2.ZERO
	cl.add_child(bg)

	var sec_h = sh / 4.0
	var sec_w = left_w - 8

	var s1 = _build_section(sec_w, sec_h, 4, cl, _build_preview(sec_w, sec_h - 28))
	s1.header.text = "▼ 配置"

	var eq_content = _make_scroll_vbox(sec_w, sec_h - 28)
	_add_group(_vb(eq_content), sec_w, "武器", WEAPONS, "weapon")
	_add_group(_vb(eq_content), sec_w, "板甲", ARMORS, "armor")
	_add_group(_vb(eq_content), sec_w, "护腿", LEGGINGS, "leggings")
	_add_group(_vb(eq_content), sec_w, "板盔", HELMETS, "helmet")
	_add_group(_vb(eq_content), sec_w, "板靴", BOOTS, "boots")
	var s2 = _build_section(sec_w, sec_h, 4 + sec_h, cl, eq_content)
	s2.header.text = "▼ 装备"

	var active_content = _make_scroll_vbox(sec_w, sec_h - 28)
	_add_group(_vb(active_content), sec_w, "主动道具", ACTIVE_ITEMS, "active")
	var s3 = _build_section(sec_w, sec_h, 4 + sec_h * 2, cl, active_content)
	s3.header.text = "▼ 主动道具"

	var ai_content = _make_scroll_vbox(sec_w, sec_h - 28)
	_add_group(_vb(ai_content), sec_w, "AI 行为", AI_OPTIONS, "ai")
	var s4 = _build_section(sec_w, sec_h, 4 + sec_h * 3, cl, ai_content)
	s4.header.text = "▼ AI"

	# 右侧卡片区
	var rx = left_w + 8
	var rw = sw - rx - 4
	var scroll = ScrollContainer.new()
	scroll.size = Vector2(rw, sh)
	scroll.position = Vector2(rx, 0)
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	cl.add_child(scroll)

	var flow = HFlowContainer.new()
	flow.name = "CardContainer"
	flow.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	flow.mouse_filter = Control.MOUSE_FILTER_PASS
	flow.add_theme_constant_override("h_separation", 100)
	flow.add_theme_constant_override("v_separation", 20)
	scroll.add_child(flow)

	# 扫描生成的兵种文件夹，加载已保存的兵种卡片
	_load_saved_troops()

	# 底边 UI（一直可见，不受 F12 影响）
	_build_bottom_ui()

# 创建一个可折叠段
func _build_section(w: float, h: float, y: float, parent: Node, body: Control) -> Dictionary:
	var panel = Panel.new()
	panel.size = Vector2(w, h)
	panel.position = Vector2(4, y)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	parent.add_child(panel)

	var hdr = Button.new()
	hdr.size = Vector2(w, 26)
	hdr.position = Vector2(0, 0)
	hdr.alignment = HORIZONTAL_ALIGNMENT_LEFT
	hdr.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	hdr.add_theme_stylebox_override("normal", _flat_style(Color(0.06, 0.12, 0.25)))
	hdr.add_theme_stylebox_override("hover", _flat_style(Color(0.10, 0.18, 0.35)))
	hdr.add_theme_stylebox_override("pressed", _flat_style(Color(0.06, 0.12, 0.25)))
	panel.add_child(hdr)

	body.position = Vector2(0, 28)
	body.size = Vector2(w, h - 28)
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	# body 已经是 ScrollContainer 了
	panel.add_child(body)

	var expanded = true
	hdr.pressed.connect(func():
		expanded = not expanded
		body.visible = expanded
		hdr.text = ("▼ " if expanded else "▶ ") + "测试配置"
	)
	return {"header": hdr, "body": body}


func _flat_style(c: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
	s.content_margin_left = 6
	s.content_margin_right = 6
	s.content_margin_top = 2
	s.content_margin_bottom = 2
	return s


# 创建一个可滚动的 VBoxContainer 面板
func _make_scroll_vbox(w: float, h: float) -> ScrollContainer:
	var sc = ScrollContainer.new()
	sc.size = Vector2(w, h)
	sc.mouse_filter = Control.MOUSE_FILTER_PASS
	var vb = VBoxContainer.new()
	vb.name = "VB"
	vb.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	vb.mouse_filter = Control.MOUSE_FILTER_PASS
	vb.add_theme_constant_override("separation", 2)
	sc.add_child(vb)
	return sc


# 获取 Scroll 内部的 VBoxContainer
func _vb(sc: ScrollContainer) -> VBoxContainer:
	return sc.find_child("VB", true, false) as VBoxContainer


# 构建预览段
func _build_preview(w: float, h: float) -> ScrollContainer:
	var sc = _make_scroll_vbox(w, h)
	var vb = _vb(sc)

	var name_lbl = Label.new()
	name_lbl.text = "角色名称:"
	name_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	name_lbl.add_theme_font_size_override("font_size", 12)
	vb.add_child(name_lbl)

	var name_row = HBoxContainer.new()
	name_row.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	name_row.add_theme_constant_override("separation", 4)
	vb.add_child(name_row)

	var name_in = LineEdit.new()
	name_in.name = "NameInput"
	name_in.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	name_in.placeholder_text = "输入名称..."
	name_in.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	name_in.add_theme_stylebox_override("normal", _flat_style(Color(0.12, 0.12, 0.18)))
	name_in.text_changed.connect(func(_t): _update_preview())
	name_in.custom_minimum_size = Vector2(0, 24)
	name_row.add_child(name_in)

	var save_btn = Button.new()
	save_btn.text = "保存"
	save_btn.custom_minimum_size = Vector2(50, 24)
	save_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	save_btn.add_theme_stylebox_override("normal", _flat_style(Color(0.12, 0.40, 0.12)))
	save_btn.add_theme_stylebox_override("hover", _flat_style(Color(0.18, 0.55, 0.18)))
	save_btn.add_theme_stylebox_override("pressed", _flat_style(Color(0.08, 0.30, 0.08)))
	save_btn.pressed.connect(_on_save)
	name_row.add_child(save_btn)

	var eq_lbl = Label.new()
	eq_lbl.name = "ConfigLabel"
	eq_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	eq_lbl.add_theme_font_size_override("font_size", 10)
	eq_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	eq_lbl.custom_minimum_size = Vector2(0, 50)
	vb.add_child(eq_lbl)

	var zombie_btn = Button.new()
	zombie_btn.text = "🟢 生成僵尸"
	zombie_btn.custom_minimum_size = Vector2(0, 28)
	zombie_btn.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	zombie_btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	zombie_btn.add_theme_stylebox_override("normal", _flat_style(Color(0.40, 0.08, 0.08)))
	zombie_btn.add_theme_stylebox_override("hover", _flat_style(Color(0.55, 0.12, 0.12)))
	zombie_btn.add_theme_stylebox_override("pressed", _flat_style(Color(0.30, 0.06, 0.06)))
	zombie_btn.pressed.connect(func():
		var soldier = ZOMBIE_TEMPLATE.instantiate()
		var slots: Array[PackedScene] = []

		var weapon_roll = randi() % 100
		var weapon_p = ""
		if weapon_roll <= 4:
			weapon_p = "铁剑"
		elif weapon_roll <= 6:
			weapon_p = "金剑"
		elif weapon_roll <= 9:
			weapon_p = "铁斧"
		elif weapon_roll <= 10:
			weapon_p = "金斧"
		if weapon_p != "":
			slots.append(load(_path_for_name(weapon_p)))
		else:
			slots.append(ZOMBIE_CLAW)

		for entry in ["armor", "leggings", "helmet", "boots"]:
			var slot_roll = randi() % 100
			var item_name = ""
			if slot_roll <= 2:
				match entry:
					"armor": item_name = "金板甲"
					"leggings": item_name = "金护腿"
					"helmet": item_name = "金板盔"
					"boots": item_name = "金板靴"
			elif slot_roll <= 7:
				match entry:
					"armor": item_name = "铁板甲"
					"leggings": item_name = "铁护腿"
					"helmet": item_name = "铁板盔"
					"boots": item_name = "铁板靴"
			elif slot_roll <= 18:
				match entry:
					"armor": item_name = "链甲"
					"leggings": item_name = "链护腿"
					"helmet": item_name = "链盔"
					"boots": item_name = "链靴"
			if item_name != "":
				var p = _path_for_name(item_name)
				if p:
					slots.append(load(p))

		soldier.equipment_slots = slots
		var x = 300
		var tier = randi() % 3
		soldier.position = Vector2(x, [-1.0, 0.0, 1.0][tier])
		soldier._tier = tier
		soldier.scale = Vector2(3, 3)
		soldier.camp = 1
		soldier.auto_move = 1
		add_child(soldier)
		soldier.health_current = 5.0
	)
	vb.add_child(zombie_btn)

	var eat_btn = Button.new()
	eat_btn.text = "🍔 AI吃东西测试"
	eat_btn.custom_minimum_size = Vector2(0, 28)
	eat_btn.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	eat_btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	eat_btn.add_theme_stylebox_override("normal", _flat_style(Color(0.12, 0.12, 0.40)))
	eat_btn.add_theme_stylebox_override("hover", _flat_style(Color(0.18, 0.18, 0.55)))
	eat_btn.add_theme_stylebox_override("pressed", _flat_style(Color(0.08, 0.08, 0.30)))
	eat_btn.pressed.connect(func():
		var soldier = ZOMBIE_HUNGRY.instantiate()
		var x = 300
		var tier = randi() % 3
		soldier.position = Vector2(x, [-1.0, 0.0, 1.0][tier])
		soldier._tier = tier
		soldier.scale = Vector2(3, 3)
		soldier.camp = 1
		soldier.auto_move = 1
		add_child(soldier)
	)
	vb.add_child(eat_btn)

	return sc


func _update_preview():
	var name_in = $CanvasLayer.find_child("NameInput", true, false) as LineEdit
	var eq_lbl = $CanvasLayer.find_child("ConfigLabel", true, false) as Label
	if not name_in or not eq_lbl:
		return
	_config.name = name_in.text

	var parts = []
	if _config.weapon: parts.append("武器:" + _config.weapon["name"])
	if _config.armor: parts.append("甲:" + _config.armor["name"])
	if _config.leggings: parts.append("腿:" + _config.leggings["name"])
	if _config.helmet: parts.append("盔:" + _config.helmet["name"])
	if _config.boots: parts.append("靴:" + _config.boots["name"])
	if _config.active: parts.append("盾:" + _config.active["name"])
	if _config.ai.size() > 0:
		var ai_names = []
		for a in _config.ai:
			ai_names.append(a.name)
		parts.append("AI:" + ",".join(ai_names))

	var lines = []
	var line = ""
	for p in parts:
		if line.length() + p.length() > 24:
			lines.append(line)
			line = p
		else:
			line += ("  " if line != "" else "") + p
	if line != "":
		lines.append(line)
	var prefix = _config.name if _config.name != "" else ""
	eq_lbl.text = (prefix + "\n" if prefix != "" else "") + "\n".join(lines)


const GENERATED_DIR = "res://sence/Fight/生成的兵种/"

func _on_save():
	if _config.name == "":
		_config.name = "无名氏"
	var tmpl = _config.duplicate(true)

	# ====== 写文件 ======
	var name = tmpl.name
	# 文件名防注入
	var safe_name = name.replace("/", "_").replace("\\", "_").replace(":", "_")

	# 建文件夹（同名则加序号）
	var folder_path = GENERATED_DIR + safe_name
	var counter = 2
	while DirAccess.dir_exists_absolute(folder_path):
		folder_path = GENERATED_DIR + safe_name + "_" + str(counter)
		counter += 1
	DirAccess.make_dir_recursive_absolute(folder_path)

	# 生成一个模板 ID（用作这个类别的天生烙印）
	var template_id = randi()

	# 采集装备名称，用于 .gd 备注
	var equip_names: Array[String] = []
	for k in ["weapon", "armor", "leggings", "helmet", "boots"]:
		var item = tmpl.get(k)
		if item: equip_names.append(item.name)
	var active_name = ""
	var active_item = tmpl.get("active")
	if active_item: active_name = active_item.name
	var ai_names: Array[String] = []
	for a in tmpl.ai: ai_names.append(a.name)

	# 复制角色样板.gd → 文件夹/角色名.gd，并注入 TEMPLATE_ID + 装备备注
	var gd_src = "res://sence/Fight/角色样板/角色样板.gd"
	var gd_dst = folder_path + "/" + safe_name + ".gd"
	var gd_content = FileAccess.get_file_as_string(gd_src)
	var gd_lines = gd_content.split("\n")
	var note = "# 装备: [" + ", ".join(equip_names) + "]"
	if active_name != "":
		note += " 主动: [" + active_name + "]"
	if ai_names.size() > 0:
		note += "  AI: [" + ", ".join(ai_names) + "]"
	# 在 extends 行后插入：const → 空行 → 备注
	var insert_at = 1
	gd_lines.insert(insert_at, note)
	gd_lines.insert(insert_at, "")
	gd_lines.insert(insert_at, "const TEMPLATE_ID = " + str(template_id))
	var f = FileAccess.open(gd_dst, FileAccess.WRITE)
	f.store_string("\n".join(gd_lines))
	f.close()

	# 生成 .tscn（从零构建，包含三个数组：equipment_slots / active_slots / ai_modules）
	var equip_paths: Array[String] = []
	# 护腿排第一（先渲染，在最底层）
	for k in ["leggings", "weapon", "armor", "helmet", "boots"]:
		var item = tmpl.get(k)
		if item and item.get("ps"):
			var p = item.ps.resource_path
			if p not in equip_paths:
				equip_paths.append(p)

	var active_paths: Array[String] = []
	active_item = tmpl.get("active")
	if active_item and active_item.get("ps"):
		active_paths.append(active_item.ps.resource_path)

	var ai_paths: Array[String] = []
	for a in tmpl.ai:
		var p = a.res.resource_path
		if p not in ai_paths:
			ai_paths.append(p)

	var lines: Array[String] = []
	lines.append("[gd_scene format=3]")
	lines.append("")

	var next_id = 1
	lines.append('[ext_resource type="Script" path="' + gd_dst + '" id="' + str(next_id) + '"]')
	next_id += 1
	lines.append('[ext_resource type="SpriteFrames" path="res://rescourse/object/character/humanlike/player_pieces/def/def.tres" id="' + str(next_id) + '"]')
	next_id += 1
	lines.append('[ext_resource type="SpriteFrames" path="res://rescourse/object/character/humanlike/player_pieces/def/def_outline.tres" id="' + str(next_id) + '"]')
	next_id += 1

	var equip_ids: Array[int] = []
	for p in equip_paths:
		lines.append('[ext_resource type="PackedScene" path="' + p + '" id="' + str(next_id) + '"]')
		equip_ids.append(next_id)
		next_id += 1

	var active_ids: Array[int] = []
	for p in active_paths:
		lines.append('[ext_resource type="PackedScene" path="' + p + '" id="' + str(next_id) + '"]')
		active_ids.append(next_id)
		next_id += 1

	var ai_ids: Array[int] = []
	for p in ai_paths:
		lines.append('[ext_resource type="Resource" path="' + p + '" id="' + str(next_id) + '"]')
		ai_ids.append(next_id)
		next_id += 1

	lines.append("")
	lines.append("[sub_resource type=\"RectangleShape2D\" id=\"1\"]")
	lines.append("size = Vector2(18, 20)")
	lines.append("")

	var eq_refs = ""
	for i in equip_ids.size():
		if i > 0: eq_refs += ", "
		eq_refs += "ExtResource(\"" + str(equip_ids[i]) + "\")"

	var ac_refs = ""
	for i in active_ids.size():
		if i > 0: ac_refs += ", "
		ac_refs += "ExtResource(\"" + str(active_ids[i]) + "\")"

	var ai_refs = ""
	for i in ai_ids.size():
		if i > 0: ai_refs += ", "
		ai_refs += "ExtResource(\"" + str(ai_ids[i]) + "\")"

	lines.append("[node name=\"" + safe_name + "\" type=\"CharacterBody2D\"]")
	lines.append("script = ExtResource(\"1\")")
	lines.append("frames = ExtResource(\"2\")")
	lines.append("outline_frames = ExtResource(\"3\")")
	lines.append("template_id = " + str(template_id))
	lines.append("equipment_slots = Array[PackedScene]([" + eq_refs + "])")
	if active_ids.size() > 0:
		lines.append("active_slots = Array[PackedScene]([" + ac_refs + "])")
	if ai_ids.size() > 0:
		lines.append("ai_modules = Array[Resource]([" + ai_refs + "])")

	lines.append("")
	lines.append("[node name=\"AnimatedSprite2D_Upper\" type=\"AnimatedSprite2D\" parent=\".\"]")
	lines.append("")
	lines.append("[node name=\"AnimatedSprite2D_Lower\" type=\"AnimatedSprite2D\" parent=\".\"]")
	lines.append("")
	lines.append("[node name=\"RayCast2D\" type=\"RayCast2D\" parent=\".\"]")
	lines.append("target_position = Vector2(10, 0)")
	lines.append("")
	lines.append("[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\".\"]")
	lines.append("position = Vector2(0, 6)")
	lines.append("shape = SubResource(\"1\")")
	lines.append("")
	lines.append("[node name=\"attackTimer\" type=\"Timer\" parent=\".\"]")
	lines.append("")
	lines.append("[node name=\"SelectArea\" type=\"Area2D\" parent=\".\"]")
	lines.append("")
	lines.append("[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"SelectArea\"]")
	lines.append("position = Vector2(0, 6)")
	lines.append("shape = SubResource(\"1\")")
	lines.append("")
	lines.append("[node name=\"AttackArea\" type=\"Area2D\" parent=\".\"]")
	lines.append("")
	lines.append("[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"AttackArea\"]")
	lines.append("position = Vector2(12, 3.33)")
	lines.append("shape = SubResource(\"1\")")

	var tscn_content = "\n".join(lines)
	var tscn_dst = folder_path + "/" + safe_name + ".tscn"
	var ft = FileAccess.open(tscn_dst, FileAccess.WRITE)
	ft.store_string(tscn_content)
	ft.close()

	# 立即添加卡片
	_add_card_from_file(tscn_dst, safe_name)

	# 清空配置，防止下次保存残留数据
	_config = {
		"name": "",
		"weapon": null,
		"armor": null,
		"leggings": null,
		"helmet": null,
		"boots": null,
		"active": null,
		"ai": [],
	}
	_update_preview()


func _load_saved_troops():
	var dir = DirAccess.open(GENERATED_DIR)
	if not dir:
		return
	dir.list_dir_begin()
	var folder_name = dir.get_next()
	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			var tscn_path = GENERATED_DIR + folder_name + "/" + folder_name + ".tscn"
			if FileAccess.file_exists(tscn_path):
				_add_card_from_file(tscn_path, folder_name)
		folder_name = dir.get_next()
	dir.list_dir_end()


func _add_card_from_file(tscn_path: String, display_name: String):
	var flow = $CanvasLayer.find_child("CardContainer", true, false) as HFlowContainer
	if not flow:
		return

	var card = Panel.new()
	card.size = Vector2(100, 50)
	card.add_theme_stylebox_override("panel", _flat_style(Color(0.12, 0.12, 0.18)))

	var bar = ColorRect.new()
	bar.size = Vector2(100, 4)
	bar.position = Vector2(0, 0)
	bar.color = Color(0.4, 0.4, 0.4)
	card.add_child(bar)

	var nl = Label.new()
	nl.text = display_name
	nl.size = Vector2(80, 20)
	nl.position = Vector2(4, 6)
	nl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	nl.add_theme_font_size_override("font_size", 9)
	card.add_child(nl)

	# 删除
	var dx = Button.new()
	dx.size = Vector2(14, 14)
	dx.position = Vector2(82, 6)
	dx.text = "×"
	dx.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	dx.add_theme_font_size_override("font_size", 7)
	dx.add_theme_stylebox_override("normal", _flat_style(Color(0.15, 0.08, 0.08)))
	dx.add_theme_stylebox_override("hover", _flat_style(Color(0.25, 0.12, 0.12)))
	var folder_path = tscn_path.get_base_dir()
	dx.pressed.connect(func():
		_recursive_delete(folder_path)
		card.queue_free()
	)
	card.add_child(dx)

	var bl = Button.new()
	bl.size = Vector2(36, 18)
	bl.position = Vector2(4, 28)
	bl.text = "←"
	bl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	bl.add_theme_font_size_override("font_size", 8)
	bl.add_theme_stylebox_override("normal", _flat_style(Color(0.08, 0.25, 0.40)))
	bl.add_theme_stylebox_override("hover", _flat_style(Color(0.12, 0.35, 0.55)))
	bl.add_theme_stylebox_override("pressed", _flat_style(Color(0.06, 0.18, 0.30)))
	bl.pressed.connect(func(): _spawn_from_file(tscn_path, 0))
	card.add_child(bl)

	var br = Button.new()
	br.size = Vector2(36, 18)
	br.position = Vector2(48, 28)
	br.text = "→"
	br.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	br.add_theme_font_size_override("font_size", 8)
	br.add_theme_stylebox_override("normal", _flat_style(Color(0.40, 0.08, 0.08)))
	br.add_theme_stylebox_override("hover", _flat_style(Color(0.55, 0.12, 0.12)))
	br.add_theme_stylebox_override("pressed", _flat_style(Color(0.30, 0.06, 0.06)))
	br.pressed.connect(func(): _spawn_from_file(tscn_path, 1))
	card.add_child(br)

	flow.add_child(card)


func _recursive_delete(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var name = dir.get_next()
	while name != "":
		var full = path + "/" + name
		if dir.current_is_dir():
			_recursive_delete(full)
		else:
			DirAccess.remove_absolute(full)
		name = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)


func _spawn_from_file(tscn_path: String, camp_id: int):
	var soldier = load(tscn_path).instantiate()
	var x = -200 if camp_id == 0 else 300
	var tier = randi() % 3
	soldier.position = Vector2(x, [-1.0, 0.0, 1.0][tier])
	soldier._tier = tier
	soldier.scale = Vector2(3, 3)
	soldier.camp = camp_id
	soldier.auto_move = 1
	if camp_id == 0:
		soldier.ai_modules.clear()
		soldier.ai_data = null
	add_child(soldier)


func _path_for_name(name: String) -> String:
	for dict in [WEAPONS, ARMORS, LEGGINGS, HELMETS, BOOTS]:
		if dict.has(name):
			return dict[name]
	return ""




# 在 VBoxContainer 里加一组物品按钮
func _add_group(vbox: VBoxContainer, w: float, title: String, dict: Dictionary, config_key: String):
	var lbl = Label.new()
	lbl.text = title
	lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(lbl)

	var hb = HBoxContainer.new()
	hb.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	hb.add_theme_constant_override("separation", 2)
	vbox.add_child(hb)

	var idx = 0
	# 无选项（武器用拳代替，不加无）
	if config_key != "weapon":
		var none_btn = Button.new()
		none_btn.text = "无"
		none_btn.custom_minimum_size = Vector2(w / 3.0 - 4, 20)
		none_btn.size = Vector2(w / 3.0 - 4, 20)
		none_btn.add_theme_font_size_override("font_size", 8)
		none_btn.add_theme_stylebox_override("normal", _flat_style(Color(0.08, 0.08, 0.12)))
		none_btn.add_theme_stylebox_override("hover", _flat_style(Color(0.12, 0.12, 0.18)))
		none_btn.add_theme_stylebox_override("pressed", _flat_style(Color(0.06, 0.06, 0.10)))
		none_btn.pressed.connect(func(k=config_key):
			if k == "ai":
				_config[k].clear()
			else:
				_config[k] = null
			_update_preview()
		)
		hb.add_child(none_btn)
		idx += 1
	for name in dict.keys():
		var path = dict[name]
		var btn = Button.new()
		btn.text = name
		btn.custom_minimum_size = Vector2(w / 3.0 - 4, 20)
		btn.size = Vector2(w / 3.0 - 4, 20)
		btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		btn.add_theme_font_size_override("font_size", 8)
		btn.add_theme_stylebox_override("normal", _flat_style(Color(0.12, 0.12, 0.20)))
		btn.add_theme_stylebox_override("hover", _flat_style(Color(0.18, 0.18, 0.28)))
		btn.add_theme_stylebox_override("pressed", _flat_style(Color(0.08, 0.08, 0.14)))
		btn.pressed.connect(func(n=name, p=path, k=config_key):
			if k == "ai":
				var found = false
				for a in _config[k]:
					if a.name == n:
						_config[k].erase(a)
						found = true
						break
				if not found:
					var res = load(p) as Resource
					if res:
						_config[k].append({"name": n, "res": res})
			else:
				var ps = load(p) as PackedScene
				if ps:
					_config[k] = {"name": n, "ps": ps}
			_update_preview()
		)
		hb.add_child(btn)
		idx += 1
		if idx % 3 == 0:
			hb = HBoxContainer.new()
			hb.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
			hb.add_theme_constant_override("separation", 2)
			vbox.add_child(hb)

	# 移除最后一个可能多余的空 HBox
	if hb.get_child_count() == 0:
		vbox.remove_child(hb)
		hb.queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_F12 and event.pressed and not event.echo:
		var cl = $CanvasLayer
		cl.visible = not cl.visible
		return
	if event is InputEventKey and event.physical_keycode == KEY_F11 and event.pressed and not event.echo:
		if _test_window and is_instance_valid(_test_window):
			var n = _option_items.size() + 1
			_option_items.append("测试物品" + str(n))
			for c in _option_content.get_children():
				c.queue_free()
			var rows = _option_items.size()
			_option_content.size = Vector2(306, rows * 40)
			var opt_tex = load("res://rescourse/object/UI/windowsui/选项.png")
			var icon_tex = load("res://rescourse/object/UI/windowsui/测试物品图标.png")
			for idx in _option_items.size():
				var opt_slot = Control.new()
				opt_slot.position = Vector2(0, idx * 40)
				opt_slot.size = Vector2(306, 40)
				_option_content.add_child(opt_slot)
				var bg = TextureRect.new()
				bg.texture = opt_tex
				bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				bg.position = Vector2.ZERO
				opt_slot.add_child(bg)
				var icon = TextureRect.new()
				icon.texture = icon_tex
				icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				icon.position = Vector2(4, 4)
				opt_slot.add_child(icon)
				var opt_font = preload("res://sence/ui/pixel_font.gd").get_font()
				var label_wrap = Control.new()
				label_wrap.position = Vector2(44, 5)
				label_wrap.size = Vector2(54, 12)
				label_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
				opt_slot.add_child(label_wrap)
				var shadow = Label.new()
				shadow.anchor_right = 1.0
				shadow.anchor_bottom = 1.0
				shadow.position = Vector2(1, 1)
				shadow.add_theme_font_override("font", opt_font)
				shadow.add_theme_font_size_override("font_size", 12)
				shadow.add_theme_color_override("font_color", Color(0, 0, 0, 1))
				shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				shadow.text = _option_items[idx]
				label_wrap.add_child(shadow)
				var front = Label.new()
				front.anchor_right = 1.0
				front.anchor_bottom = 1.0
				front.add_theme_font_override("font", opt_font)
				front.add_theme_font_size_override("font_size", 12)
				front.add_theme_color_override("font_color", Color.WHITE)
				front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				front.text = _option_items[idx]
				label_wrap.add_child(front)
				label_wrap.scale = Vector2(2, 2)
			# 同步滚动条
			_option_content.position.y = 0
			if _scroll_btn:
				_scroll_btn.position.y = 120 + 2
				var mt = _scroll_base.size.y - _scroll_btn.texture.get_size().y - 4
				var ct = _option_content.size.y - _option_clip.size.y
				var r = clamp(-_option_content.position.y / ct if ct > 0 else 0.0, 0.0, 1.0)
				_scroll_btn.position.y = 120 + 2 + mt * r
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_start = get_global_mouse_position()
			_drag_end = _drag_start
			_dragging = false
			if get_tree().debug_collisions_hint:
				print("点击: x=", get_global_mouse_position().x, " y=", get_global_mouse_position().y)
			PiecesParent.deselect_all()
		else:
			if _dragging:
				_drag_end = get_global_mouse_position()
				_dragging = false
				queue_redraw()
				var rect = Rect2(_drag_start, Vector2.ZERO).expand(_drag_end)
				PiecesParent.box_select(rect)
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		_drag_end = get_global_mouse_position()
		if not _dragging and _drag_end.distance_to(_drag_start) > 8:
			_dragging = true
		if _dragging:
			queue_redraw()


func _draw():
	if not _dragging:
		return
	draw_rect(Rect2(_drag_start, _drag_end - _drag_start), Color.WHITE, false, 2.0)


func _build_bottom_ui():
	var cl = CanvasLayer.new()
	cl.layer = 10
	add_child(cl)

	var bar = ColorRect.new()
	bar.color = Color(0.06, 0.06, 0.12, 0.92)
	bar.anchor_left = 0.0
	bar.anchor_top = 1.0
	bar.anchor_right = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_top = -80
	cl.add_child(bar)

	var btn = Button.new()
	btn.text = ""
	btn.position = Vector2(8, 8)
	btn.size = Vector2(64, 64)
	btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var normal_bg = StyleBoxFlat.new()
	normal_bg.bg_color = Color(0.15, 0.15, 0.25)
	normal_bg.set_corner_radius_all(4)
	var hover_bg = StyleBoxFlat.new()
	hover_bg.bg_color = Color(0.20, 0.20, 0.35)
	hover_bg.set_corner_radius_all(4)
	var pressed_bg = StyleBoxFlat.new()
	pressed_bg.bg_color = Color(0.10, 0.10, 0.20)
	pressed_bg.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", normal_bg)
	btn.add_theme_stylebox_override("hover", hover_bg)
	btn.add_theme_stylebox_override("pressed", pressed_bg)
	bar.add_child(btn)

	var btn_label = preload("res://sence/ui/pixel_label_button.gd").new()
	btn_label.text = "测试"
	btn_label.position = Vector2(0, 0)
	btn_label.size = Vector2(32, 32)
	btn.add_child(btn_label)

	btn.pressed.connect(_open_test_window)


func _open_test_window():
	var WindowScript = load("res://sence/ui/window_parent.gd")
	if not WindowScript:
		return
	var win = WindowScript.new()
	win.window_width = 384
	win.window_height = 308
	var viewport = get_viewport()
	win.window_pos_x = int((viewport.size.x - 384) / 2)
	win.window_pos_y = int((viewport.size.y - 308) / 2)
	_ensure_window_layer().add_child(win)
	win.set_title("模板配置")
	_test_window = win

	_option_items.clear()
	for i in range(7):
		_option_items.append("测试物品" + str(i + 1))

	# 在内容区左上角放物品槽位网格，中间 2x3 替换为角色显示底板
	var rows = 3
	var cols = 4
	var slot = 36
	var total_w = cols * slot
	var total_h = rows * slot
	var holder = Control.new()
	holder.position = Vector2(20, 44)
	holder.size = Vector2(356, 256)
	win.add_child(holder)

	for r in range(rows):
		for c in range(cols):
			if c >= 1 and c <= 2:
				continue
			var s = preload("res://sence/ui/item_slot.gd").new()
			s.position = Vector2(c * slot, r * slot)
			holder.add_child(s)

	var char_bg = TextureRect.new()
	char_bg.texture = load("res://rescourse/object/UI/windowsui/角色显示底板.png")
	char_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	char_bg.position = Vector2(1 * slot, 0)
	holder.add_child(char_bg)

	# 在角色底板上显示角色，3x 居中
	var char_node = PREVIEW_SCENE.instantiate()
	char_node.setup({})
	char_node.scale = Vector2(3, 3)
	char_node.position = Vector2(72, 35)
	holder.add_child(char_node)

	# 输入框，放在格子右侧，垂直居中
	var input_holder = Control.new()
	input_holder.position = Vector2(144 + 20, 0)
	input_holder.size = Vector2(180, 38)
	holder.add_child(input_holder)

	var input_bg = TextureRect.new()
	input_bg.texture = load("res://rescourse/object/UI/windowsui/输入框_活跃.png")
	input_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	input_bg.position = Vector2.ZERO
	input_holder.add_child(input_bg)

	var input_wrap = Control.new()
	input_wrap.position = Vector2(5, -4)
	input_wrap.size = Vector2(82, 19)
	input_wrap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	input_holder.add_child(input_wrap)

	var f = load("res://rescourse/object/UI/simsun.ttc")
	var fv = FontVariation.new()
	fv.base_font = f
	fv.set_spacing(TextServer.SPACING_GLYPH, 1)
	var input_shadow = Label.new()
	input_shadow.position = Vector2(1, 5)
	input_shadow.size = Vector2(82, 19)
	input_shadow.add_theme_font_override("font", fv)
	input_shadow.add_theme_font_size_override("font_size", 12)
	input_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	input_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	input_wrap.add_child(input_shadow)

	var input_edit = LineEdit.new()
	input_edit.anchor_right = 1.0
	input_edit.anchor_bottom = 1.0
	input_edit.add_theme_font_override("font", fv)
	input_edit.add_theme_font_size_override("font_size", 12)
	input_edit.add_theme_color_override("font_color", Color.WHITE)
	input_edit.add_theme_color_override("background_color", Color(0, 0, 0, 0))
	input_edit.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	input_edit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	input_edit.add_theme_constant_override("minimum_character_width", 0)
	input_edit.placeholder_text = ""
	input_edit.text_changed.connect(func(t): input_shadow.text = t)
	input_wrap.add_child(input_edit)

	input_wrap.scale = Vector2(2, 2)

	# 输入框下方两个按钮，右对齐输入框
	var btn_tex = load("res://rescourse/object/UI/windowsui/按钮.png")
	for i in range(2):
		var bx = 0 if i == 0 else 100
		var btn_bg = TextureRect.new()
		btn_bg.texture = btn_tex
		btn_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		btn_bg.position = Vector2(144 + 20 + bx, 50)
		holder.add_child(btn_bg)

		var btn_label = preload("res://sence/ui/pixel_label_center.gd").new()
		btn_label.text = "确认" if i == 0 else "清空"
		btn_label.font_color = Color.BLACK
		btn_label.position = Vector2(144 + 20 + bx, 50)
		btn_label.size = Vector2(40, 20)
		holder.add_child(btn_label)

	# 选项展示窗，放在格子下方
	var option_bg = TextureRect.new()
	option_bg.texture = load("res://rescourse/object/UI/windowsui/选项展示窗.png")
	option_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	option_bg.position = Vector2(0, 120)
	holder.add_child(option_bg)

	# 纯 Control 裁剪区替代 ScrollContainer，手动管理滚动
	var clip = Control.new()
	clip.clip_contents = true
	clip.position = Vector2(4, 124)
	clip.size = Vector2(306, 116)
	clip.mouse_filter = Control.MOUSE_FILTER_STOP
	holder.add_child(clip)
	_option_clip = clip

	var option_content = Control.new()
	option_content.position = Vector2.ZERO
	option_content.size = Vector2(306, 120)
	clip.add_child(option_content)
	_option_content = option_content

	var opt_tex = load("res://rescourse/object/UI/windowsui/选项.png")
	var icon_tex = load("res://rescourse/object/UI/windowsui/测试物品图标.png")

	var build_options = func():
		for c in option_content.get_children():
			c.queue_free()
		option_content.size = Vector2(306, _option_items.size() * 40)
		for idx in _option_items.size():
			var opt_slot = Control.new()
			opt_slot.position = Vector2(0, idx * 40)
			opt_slot.size = Vector2(306, 40)
			option_content.add_child(opt_slot)

			var bg = TextureRect.new()
			bg.texture = opt_tex
			bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			bg.position = Vector2.ZERO
			opt_slot.add_child(bg)

			var icon = TextureRect.new()
			icon.texture = icon_tex
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.position = Vector2(4, 4)
			opt_slot.add_child(icon)

			var opt_font = preload("res://sence/ui/pixel_font.gd").get_font()
			var label_wrap = Control.new()
			label_wrap.position = Vector2(44, 5)
			label_wrap.size = Vector2(54, 12)
			label_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			opt_slot.add_child(label_wrap)

			var shadow = Label.new()
			shadow.anchor_right = 1.0
			shadow.anchor_bottom = 1.0
			shadow.position = Vector2(1, 1)
			shadow.add_theme_font_override("font", opt_font)
			shadow.add_theme_font_size_override("font_size", 12)
			shadow.add_theme_color_override("font_color", Color(0, 0, 0, 1))
			shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			shadow.text = _option_items[idx]
			label_wrap.add_child(shadow)

			var front = Label.new()
			front.anchor_right = 1.0
			front.anchor_bottom = 1.0
			front.add_theme_font_override("font", opt_font)
			front.add_theme_font_size_override("font_size", 12)
			front.add_theme_color_override("font_color", Color.WHITE)
			front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			front.text = _option_items[idx]
			label_wrap.add_child(front)

			label_wrap.scale = Vector2(2, 2)

	build_options.call()

 	# 右侧滚动条
	var scroll_base = TextureRect.new()
	scroll_base.texture = load("res://rescourse/object/UI/windowsui/滚动条底座.png")
	scroll_base.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scroll_base.position = Vector2(316, 120)
	holder.add_child(scroll_base)
	_scroll_base = scroll_base

	var scroll_btn = TextureRect.new()
	scroll_btn.texture = load("res://rescourse/object/UI/windowsui/滚动条按钮.png")
	scroll_btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scroll_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_btn.position = Vector2(316 + 2, 120 + 2)
	holder.add_child(scroll_btn)
	_scroll_btn = scroll_btn

	var max_travel = scroll_base.size.y - scroll_btn.texture.get_size().y - 4
	var content_travel = option_content.size.y - clip.size.y

	# 透明的轨道覆盖层处理所有拖拽事件（自身不移动，坐标不会漂移）
	var track_area = Control.new()
	track_area.position = Vector2(316, 120)
	track_area.size = scroll_base.size
	track_area.mouse_filter = Control.MOUSE_FILTER_STOP
	holder.add_child(track_area)

	var dragging = false
	var drag_offset = 0.0

	track_area.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = event.pressed
				if dragging:
					drag_offset = get_global_mouse_position().y - scroll_btn.global_position.y
		if event is InputEventMouseMotion and dragging:
			var target_global_y = get_global_mouse_position().y - drag_offset
			var target_local_y = target_global_y - holder.global_position.y
			var new_btn_y = clamp(target_local_y, 120 + 2, 120 + 2 + max_travel)
			var r = (new_btn_y - (120 + 2)) / max_travel if max_travel > 0 else 0.0
			r = clamp(r, 0.0, 1.0)
			option_content.position.y = -content_travel * r
			scroll_btn.position.y = new_btn_y
	)

	clip.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			var step = 40.0 / content_travel if content_travel > 0 else 0.0
			var r = -option_content.position.y / content_travel if content_travel > 0 else 0.0
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				r = clamp(r - step, 0.0, 1.0)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				r = clamp(r + step, 0.0, 1.0)
			option_content.position.y = -content_travel * r
			scroll_btn.position.y = 120 + 2 + max_travel * r
	)


func _ensure_window_layer() -> CanvasLayer:
	if not _window_layer:
		_window_layer = CanvasLayer.new()
		_window_layer.layer = 128
		add_child(_window_layer)
	return _window_layer
