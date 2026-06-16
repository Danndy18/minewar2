extends CharacterBody2D

var camp = 0
var speed:float = 5000
var direction:Vector2 = Vector2(1,0)
var health = 0
var healthUp = 0
var damage = 0
@onready var Anima = $AnimatedSprite2D


var frameEnd = 5

func _ready() -> void:

	pass

func _physics_process(delta: float) -> void:
	#移动
	#var current_position := global_position
	#var next_position := current_position + direction * speed * delta
	#global_position = next_position
	
	velocity = direction * speed * delta
	move_and_slide()
	
	#攻击
	var isCollision = get_last_slide_collision()
	if isCollision != null:
		var collisionId = isCollision.get_collider() 
		Anima.play("attack")
		if Anima.frame == frameEnd:
			collisionId.health -=1
	else:
		Anima.play("walk")
		
	#死亡
	if health <= 0: queue_free()
	pass
