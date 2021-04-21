extends Area2D

const SPEED = 500
var velocity = Vector2()

var direction_x = 1

var crash = false

func set_carrot_direction(dir):
	direction_x = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if !crash:
		velocity.x = SPEED * delta * direction_x

		translate(velocity)
		$AnimatedSprite.play("shoot")
	else:
		velocity.x = 0
		translate(velocity)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_carrot_body_entered(body):
	crash = true
	$AnimatedSprite.play("smush")
	if "skeleton" in body.name:
		body.dead()


func _on_AnimatedSprite_animation_finished():
	if crash:
		queue_free()
