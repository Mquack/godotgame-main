extends Area2D

onready var tween_pos = get_node("tween_pos")
onready var sprite = get_node("AnimatedSprite")

func _ready():
	tween_pos.interpolate_property(sprite, "scale" ,
									sprite.get_scale(),
									Vector2(1.5, 1.5),
									0.5,
									Tween.TRANS_QUAD,
									Tween.EASE_IN_OUT)
	tween_pos.interpolate_property(sprite, "rotation_degrees",
									0,
									180,
									0.5,
									Tween.TRANS_QUAD,
									Tween.EASE_OUT)


#func _process(delta):
#	pass
func reward():
	print(get_parent().get_node("player").carrot_ammo)
	get_parent().get_node("player").carrot_ammo += 10

func carrot_grabbed():
	tween_pos.start()

func _on_c_carrot_body_entered(body):
	if body.name == "player":
		$CollisionShape2D.call_deferred("set_disabled", true)
		carrot_grabbed()
		reward()


func _on_tween_pos_tween_completed(object, key):
	queue_free()
