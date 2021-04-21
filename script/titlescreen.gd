extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/TextureButton.grab_focus()
	#$MarginContainer/VBoxContainer/VBoxContainer/TextureButton2

func _physics_process(delta):
	if $MarginContainer/VBoxContainer/VBoxContainer/TextureButton.is_hovered():
		$MarginContainer/VBoxContainer/VBoxContainer/TextureButton.grab_focus()
	if $MarginContainer/VBoxContainer/VBoxContainer/TextureButton2.is_hovered():
		$MarginContainer/VBoxContainer/VBoxContainer/TextureButton2.grab_focus()


func _on_TextureButton_pressed():
	get_tree().change_scene("res://scene/StageOne.tscn")


func _on_TextureButton2_pressed():
	get_tree().quit()
