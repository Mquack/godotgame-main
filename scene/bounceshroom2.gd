extends StaticBody2D

const TYPE = "ENEMY"
const BOUNCEABLE = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass


func _on_Area2D_area_entered(area):
	$AnimatedSprite.play("bounce")


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.play("idle")
