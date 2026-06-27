extends "res://sence/equipment/装备/主动道具/block_parent.gd"

# 发射器：方块的一种
# 速度惩罚在场景中设置 weight_mult = 0.9

const HUMAN_DISPENSER = preload("res://sence/Fight/建筑父对象/建筑子类/human_dispenser.tscn")

enum State { IDLE, PLACEMENT_CHECK }
var _state: int = State.IDLE
var _prev_held: bool = false
var _placement_area: Area2D = null
var _placement_target: Vector2 = Vector2.ZERO


func sync(parent: Node) -> void:
	super.sync(parent)

	match _state:
		State.IDLE:
			var held = parent.active_item_held
			if held and not _prev_held and not parent._building:
				var offset = 32 if parent.camp == 0 else -32
				_placement_target = parent.global_position + Vector2(offset, 0)
				_placement_area = Area2D.new()
				var shape = RectangleShape2D.new()
				shape.size = Vector2(54, 20)
				var col = CollisionShape2D.new()
				col.shape = shape
				_placement_area.add_child(col)
				_placement_area.global_position = _placement_target
				parent.get_parent().add_child(_placement_area)
				_state = State.PLACEMENT_CHECK
			else:
				parent.unguarded = true
				parent.attack_area.monitoring = false
				parent.AnimaUpper.animation = "上半身-抬手"
				parent.AnimaUpper.frame = 0
				parent.effect_pool.move_speed *= weight_mult

		State.PLACEMENT_CHECK:
			var blocked = false
			for area in _placement_area.get_overlapping_areas():
				var p = area.get_parent()
				if p and p.get("_phase") != null:
					blocked = true
					break

			if _placement_area:
				_placement_area.queue_free()
				_placement_area = null

			if not blocked:
				var bld = HUMAN_DISPENSER.instantiate()
				bld.camp = parent.camp
				bld.global_position = _placement_target
				bld.scale = Vector2(3, 3)
				parent.get_parent().add_child(bld)
				parent._building_ref = bld
				parent._building = true
				parent._build_frame = 0
				queue_free()
				return
			else:
				_state = State.IDLE

	_prev_held = parent.active_item_held
