extends Node2D


func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			print(event.is_pressed())

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

