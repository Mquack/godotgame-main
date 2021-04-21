extends Node2D

var direction = Vector2()
var distance

var speed = 100
var enemySpeedMin = 150
var enemySpeedMax = 350

var follow = false

onready var player = get_node("/root/StageOne/player")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	direction = player.global_position - self.global_position
	if direction.x > 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
		
	distance = sqrt(direction.x * direction.x + direction.y * direction.y)
	if distance < 800:
		follow = true
	else:
		follow = false
	if follow == true:

		global_position += direction.normalized() * speed * delta
		$AnimatedSprite.play("fly")
		#anim_manager("fly")
