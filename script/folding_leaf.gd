extends StaticBody2D

const TYPE = "LEAF"
const BOUNCEABLE = false

var folded = false
var returning_ani_finished = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_area_entered(area):
	if !folded:
		folded = true
		$fold_timer.start(0.5)


func _on_AnimatedSprite_animation_finished():
	if folded and !returning_ani_finished:
		$fold_timer.start(2)
	elif returning_ani_finished:
		folded = false
		$CollisionPolygon2D.set_deferred("disabled",false)


func _on_fold_timer_timeout():
	if folded and returning_ani_finished:
		$CollisionPolygon2D.set_deferred("disabled",true)
		returning_ani_finished = false
		$AnimatedSprite.play("folding")
	else:
		$AnimatedSprite.play("returning")
		returning_ani_finished = true
