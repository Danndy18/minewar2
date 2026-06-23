extends Area2D

# 装备名称（在 UI/调试中显示）
@export var equipment_name: String = ""

# 装备图标（用于 UI 物品栏显示）
@export var icon: Texture2D

# 描边图包
# 棋子描边系统自动读取此图包为此装备的主精灵创建填黑孪生精灵
# 如果不需要描边可留空
@export var outline_frames: SpriteFrames

# 主精灵跟随上半身还是下半身
# true  = 跟随上半身动画（武器、盾牌、头盔、胸甲……大部分装备）
# false = 跟随下半身动画（护腿、靴子等下装）
@export var follow_upper: bool = true

# 此装备的主精灵节点路径
# 在场景编辑器中拖拽指向 WeaponSprite / ShieldSprite / ArmorSprite 等
# 父对象用此路径自动同步动画、获取描边配对、收集死亡精灵
@export var sprite_node: NodePath

# 材质名称（木/石/金/钻石），填入后自动展开为三色调色
# 设为空或"铁"则使用原贴图色
@export var material_name: String = ""

# 调色板替换颜色（优先级高于 material_name）
# 贴图中 #959595 / #bfbfbf / #e1e1e1 / #ffffff 四级灰会被替换
@export var palette_1: Color = Color.BLACK
@export var palette_2: Color = Color.BLACK
@export var palette_3: Color = Color.BLACK
@export var palette_4: Color = Color.BLACK


const PALETTE_SHADER = preload("res://sence/equipment/着色/palette_swap.gdshader")

const MATERIAL_PALETTES: Dictionary = {
	"木": [Color(0.349, 0.263, 0.098), Color(0.525, 0.400, 0.149), Color(0.667, 0.529, 0.267), Color(0.600, 0.468, 0.212)],
	"石": [Color(0.490, 0.490, 0.490), Color(0.604, 0.604, 0.604), Color(0.710, 0.710, 0.710), Color(0.660, 0.660, 0.660)],
	"金": [Color(0.976, 0.745, 0.216), Color(0.949, 0.835, 0.369), Color(0.976, 0.976, 0.588), Color(0.963, 0.910, 0.485)],
	"钻石": [Color(0.169, 0.780, 0.675), Color(0.200, 0.922, 0.796), Color(0.663, 1.000, 0.941), Color(0.445, 0.963, 0.873)],
}


# 每帧由父对象遍历调用
# 自动将主精灵的动画/帧/旋转对齐目标部位的当前值
func sync(parent: Node) -> void:
	var spr = get_node_or_null(sprite_node) as AnimatedSprite2D
	if not spr or not spr.sprite_frames:
		return
	var target = parent.AnimaUpper if follow_upper else parent.AnimaLower
	if spr.sprite_frames.has_animation(target.animation):
		spr.animation = target.animation
		spr.frame = target.frame
	spr.rotation = target.rotation


# 返回此装备所有需要参与描边/死亡旋转的精灵
# 父对象遍历此列表统一偏移位置并收集到死亡列表
func get_equipment_sprites() -> Array:
	var spr = get_node_or_null(sprite_node) as AnimatedSprite2D
	return [spr] if spr else []


# 返回此装备所有需要描边的 [精灵, 图包] 对
# 父对象遍历此配对列表创建填黑孪生精灵
func get_outline_pairs() -> Array:
	var spr = get_node_or_null(sprite_node) as AnimatedSprite2D
	if spr and outline_frames:
		return [[spr, outline_frames]]
	return []


# 为精灵应用调色板替换 shader（替换 #959595 / #bfbfbf / #e1e1e1 / #ffffff）
func _apply_palette(spr: AnimatedSprite2D) -> void:
	if palette_1 == Color.BLACK and palette_2 == Color.BLACK and palette_3 == Color.BLACK and palette_4 == Color.BLACK:
		if material_name == "" or material_name == "铁":
			return
		var p = MATERIAL_PALETTES.get(material_name)
		if not p:
			return
		palette_1 = p[0]
		palette_2 = p[1]
		palette_3 = p[2]
		palette_4 = p[3]
	var mat = ShaderMaterial.new()
	mat.shader = PALETTE_SHADER
	mat.set_shader_parameter("replace_1", palette_1)
	mat.set_shader_parameter("replace_2", palette_2)
	mat.set_shader_parameter("replace_3", palette_3)
	mat.set_shader_parameter("replace_4", palette_4)
	spr.material = mat
