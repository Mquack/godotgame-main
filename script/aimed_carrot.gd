extends Area2D

const SPEED = 500
var velocity = Vector2()

var direction_x = (sqrt(2))/2
var direction_y = -(sqrt(2))/2
#var direction_y = -1
var crash = false

func set_carrot_direction(dir_x, dir_y):
	direction_x = dir_x
	direction_y = dir_y


func _ready():
	pass


func _physics_process(delta):
	if !crash:
		velocity.x = SPEED * delta * direction_x
		velocity.y = SPEED * delta * direction_y
		translate(velocity)
		$AnimatedSprite.play("new_shoot")
	else:
		velocity.x = 0
		velocity.y = 0
		translate(velocity)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_carrot_body_entered(body):
	crash = true
	#$CollisionShape2D.set_disabled(true)
	$AnimatedSprite.play("new_smush")


func _on_aimed_carrot_area_entered(area):
	#correct way to disable collisions, others may result in crash :(
	$CollisionShape2D.set_deferred("disabled",true)
	crash = true
	$AnimatedSprite.play("new_smush")


func _on_AnimatedSprite_animation_finished():
	if crash:
		queue_free()



