extends CanvasLayer

var org_x = 640
var org_y = 360

var cam_x
var cam_y


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cam_x = get_parent().get_node("Camera2D").get_viewport_rect().size.x
	cam_y = get_parent().get_node("Camera2D").get_viewport_rect().size.y
	#print(cam_x, cam_y)
	#var scale = cam_x/org_x
	#print("gui: ", $gui_left.position)
	#$gui_left.position = Vector2(cam_x/20, cam_y-(cam_y/10))
