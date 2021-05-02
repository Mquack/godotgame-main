extends KinematicBody2D


const CARROT2 = preload("res://scene/aimed_carrot.tscn")
const run_speed = 200
const walk_speed = 120
const gravity = 10

var velocity = Vector2()
export var speed = 120

var jump_power = -300
var ground_lvl = Vector2(0, -1)
var dubble_jump = false

var is_attacking = false
var is_dead = false
var attack_array = ["shoot0", "shoot1", "shoot2", "shoot3", "shoot4", "shoot5"]
#var look_around_array = ["look0", "look1", "look2", "look3", "look4", "look5",]

var hp = 10
const max_health = 10
var carrot_ammo = 50

var is_hurt = false
var wall_jumped = false
var wall_jump_complete = true

var looking_dir = 1

onready var health_bar = $HealthBar/HealthBar
onready var health_under = $HealthBar/HealthBar_under
onready var update_health = $HealthBar/UpdateHealth

var eventer
var eventer2

func _ready():
	$CanvasLayer_GUI/Control_HUD2/ammo_count.set_text(str(carrot_ammo))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	turn_melee_ray()
	if !is_dead:
		update_hud()
		move_char()
		#print($Camera2D.get_camera_screen_center())
		insta_death_ground()
	else:
		velocity.y += gravity
		velocity = move_and_slide(velocity, ground_lvl)


func on_health_updated(hp):
	health_bar.value = hp
	update_health.interpolate_property(health_under, "value", health_under.value, hp, 1, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	update_health.start()


func flip_him():
	var x_value = (($AnimatedSprite.get_local_mouse_position() - $Position2D_aim.position).normalized().x)
	if  x_value > 0:
		$AnimatedSprite.flip_h = false
		looking_dir = 1
		if !$AnimatedSprite.flip_h:
			$RayCast_melee.cast_to.x = abs($RayCast_melee.cast_to.x)
	else:
		$AnimatedSprite.flip_h = true
		looking_dir = -1
		if $AnimatedSprite.flip_h:
			$RayCast_melee.cast_to.x = -1 * abs($RayCast_melee.cast_to.x)


func turn_melee_ray():
	if $AnimatedSprite.flip_h:
		$AnSpfeet_back.flip_h = true
		$AnSpfeet_front.flip_h = true
		$RayCast_melee.cast_to.x = -1 * abs($RayCast_melee.cast_to.x)
	if !$AnimatedSprite.flip_h:
		$AnSpfeet_back.flip_h = false
		$AnSpfeet_front.flip_h = false
		$RayCast_melee.cast_to.x = abs($RayCast_melee.cast_to.x)

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed() and !is_attacking and !is_dead:
			eventer = (event.get_position())
			if eventer.y < 275:
				eventer2 = (get_canvas_transform().origin + $Position2D_aim.global_position)
				$CanvasLayer_GUI/Control_HUD2/disp_debug.set_text(str(eventer))
				$CanvasLayer_GUI/Control_HUD2/disp_debug2.set_text(str(eventer2))
				
				is_attacking = true
				var touch_pos = eventer - eventer2
				touch_pos = touch_pos.normalized()
				$CanvasLayer_GUI/Control_HUD2/disp_debug3.set_text(str(stepify(touch_pos.y,0.001)))
				if is_on_floor():
					velocity.x = 0
				if touch_pos.x < 0:
					$AnimatedSprite.flip_h = true
					#$AnimatedSprite_legs.flip_h = true
				else:
					$AnimatedSprite.flip_h = false
					#$AnimatedSprite_legs.flip_h = false

				if touch_pos.y < -0.981:
					$AnimatedSprite.play(attack_array[5])
				elif touch_pos.y < -0.832:
					$AnimatedSprite.play(attack_array[4])
				elif touch_pos.y < -0.556:
					$AnimatedSprite.play(attack_array[3])
				elif touch_pos.y < -0.196:
					$AnimatedSprite.play(attack_array[2])
				elif touch_pos.y < 0.196:#< 0.045:
					$AnimatedSprite.play(attack_array[1])
				else:
					$AnimatedSprite.play(attack_array[0])
				
				var carrot2 = CARROT2.instance()
				var carrot_rotation = atan2(touch_pos.y, touch_pos.x)
				
				carrot2.set_rotation(carrot_rotation)
				carrot2.set_collision_layer(64)
				carrot2.set_collision_mask(74)
				#carrot2.set_collision_layer_bit(7, true)
				carrot2.set_collision_mask_bit(7, true)

				
				if sign($Position2D.position.x) == 1:
					carrot2.set_carrot_direction(touch_pos.x, touch_pos.y)
				else:
					carrot2.set_carrot_direction(touch_pos.x, touch_pos.y)
				
				get_parent().add_child(carrot2)
				carrot2.position = $Position2D_aim.global_position
				carrot_ammo -= 1
				$shooting.play()
			
		else: eventer2 = false


func move_char():
	if !is_dead:# and !is_hurt:
		#flip_him()
		var pos_holder = ($AnimatedSprite.get_local_mouse_position() - $Position2D_aim.position).normalized()
		
			
		if Input.is_action_pressed("ui_right"):
			if wall_jump_complete:
				velocity.x = speed
			if !is_attacking:
				$AnimatedSprite.flip_h = false
				if is_on_floor() and !is_hurt:
					$AnimatedSprite.play("walk")
					$AnSpfeet_back.play("walk")
					$AnSpfeet_front.play("walk")
					
		elif Input.is_action_pressed("ui_left"):
			if wall_jump_complete:
				velocity.x = speed * -1
			if !is_attacking:
				$AnimatedSprite.flip_h = true
				if is_on_floor() and !is_hurt:
					$AnimatedSprite.play("walk")
					$AnSpfeet_back.play("walk")
					$AnSpfeet_front.play("walk")
		else:
			if is_on_floor():
				if velocity.x < 1:
					velocity.x = 0
				else:
					velocity.x -= velocity.x*0.2 
			
			if is_on_floor() and !is_attacking and !is_hurt: 
				$AnimatedSprite.play("idle")
				$AnSpfeet_back.play("idle")
				$AnSpfeet_front.play("idle")

		if Input.is_action_just_pressed("ui_select"):
			wall_jump()
			if is_on_floor():
				velocity.y = jump_power
				$AnimatedSprite.play("jump")
#				$AnSpfeet_back.play("jump")
#				$AnSpfeet_front.play("jump")
				dubble_jump = false
			elif !dubble_jump and !wall_jumped:
				velocity.y = jump_power
				$AnimatedSprite.play("jump")
#				$AnSpfeet_back.play("jump")
#				$AnSpfeet_front.play("jump")
				dubble_jump = true
			
		if !is_on_floor():
			if velocity.y > 10:
				if !is_attacking:
					$AnimatedSprite.play("fall")
					$AnSpfeet_back.play("fall")
					$AnSpfeet_front.play("fall")
		else:
			dubble_jump = false
		
		if Input.is_action_just_pressed("mouse_2") and !is_attacking:
			if is_on_floor():
				velocity.x = 0
			is_attacking = true
			$AnimatedSprite.play("melee")
			if is_on_floor():
				$AnSpfeet_back.play("melee")
				$AnSpfeet_front.play("melee")
			if $RayCast_melee.is_colliding():
				if $RayCast_melee.get_collider().get_class() == "KinematicBody2D":
					if $RayCast_melee.get_collider().TYPE == "ENEMY":
						get_node("/root/StageOne/" + ($RayCast_melee.get_collider().name)).dead(1)
		
		if Input.is_action_pressed("mouse_1") and carrot_ammo > 0 and !is_attacking:
		#if Input.is_action_just_pressed("mouse_1") and !is_attacking and carrot_ammo > 0:
			#var aim_point = (get_viewport().get_mouse_position())
			#var pos_holder = ($AnimatedSprite.get_local_mouse_position() - $Position2D_aim.position).normalized()
			is_attacking = true
			var mouse_pos = ($Position2D_aim.get_local_mouse_position())
			if is_on_floor():
				velocity.x = 0
			if pos_holder.x < 0:
				$AnimatedSprite.flip_h = true
			else:
				$AnimatedSprite.flip_h = false
			
			if pos_holder.y < -0.97:
				$AnimatedSprite.play(attack_array[5])
			elif pos_holder.y < -0.89:
				$AnimatedSprite.play(attack_array[4])
			elif pos_holder.y < -0.6:
				$AnimatedSprite.play(attack_array[3])
			elif pos_holder.y < -0.36:
				$AnimatedSprite.play(attack_array[2])
			elif pos_holder.y < 0.045:
				$AnimatedSprite.play(attack_array[1])
			else:
				$AnimatedSprite.play(attack_array[0])
			
			var carrot2 = CARROT2.instance()
			var carrot_rotation = atan2(mouse_pos.y, mouse_pos.x)
			
			carrot2.set_rotation(carrot_rotation)
			carrot2.set_collision_layer(64)
			carrot2.set_collision_mask(74)
			#carrot2.set_collision_layer_bit(7, true)
			carrot2.set_collision_mask_bit(7, true)
			
			
			if sign($Position2D.position.x) == 1:
				carrot2.set_carrot_direction(pos_holder.x, pos_holder.y)
			else:
				carrot2.set_carrot_direction(pos_holder.x, pos_holder.y)
			
			get_parent().add_child(carrot2)
			carrot2.position = $Position2D_aim.global_position
			carrot_ammo -= 1
			$shooting.play()
			#$Camera2D/Control_HUD/ammo_count.set_text(str(carrot_ammo))
		
		if Input.is_action_pressed("ui_down"):
			velocity.y += gravity + 10
		else:
			velocity.y += gravity
		#velocity.y += gravity
	velocity = move_and_slide(velocity, ground_lvl)


func wall_jump():
	if $RayCast_melee.is_colliding() and is_on_wall() and !is_on_floor():
		for i in range(get_slide_count()):
			if (get_slide_collision(i).collider.name) == "world_tiles":
				velocity.y = jump_power
				if $AnimatedSprite.flip_h:
					velocity.x = speed
				else:
					velocity.x = speed * -1
				dubble_jump = false
				wall_jumped = true
				wall_jump_complete = false
				$wall_jump_timer.start(0.6)





func update_hud():
	#$Camera2D/Control_HUD/ammo_count.set_text(str(carrot_ammo))
	$CanvasLayer_GUI/Control_HUD2/ammo_count.set_text(str(carrot_ammo))


func _on_AnimatedSprite_animation_finished():
	is_attacking = false
	is_hurt = false


func player_hit(hit:int = 1):
	if hp <= hit:
		is_dead = true
		hp = 0
		on_health_updated(hp)
		velocity = Vector2(0, 0)
		$AnimatedSprite.play("death")
		$AnSpfeet_back.visible = false
		$AnSpfeet_front.visible = false
		$audioDeath.play()
		#$CollisionShape2D.call_deferred("set_disabled", true)
		#$CollisionShape2D.set_disabled(true)
		#TODO: Eliminate collision with enemies after death.
	elif hp > hit:
		hp -= hit
		on_health_updated(hp)
		is_hurt = true
		if !is_attacking:
			$AnimatedSprite.play("hurt")


func _on_Area2D_feet_body_entered(body):
	if body.TYPE == "ENEMY":
			if body.BOUNCEABLE == true:
				velocity.y = jump_power * 1.5
				dubble_jump = false
				$AnimatedSprite.play("jump")
#				$AnSpfeet_back.play("jump")
#				$AnSpfeet_front.play("jump")
				


func insta_death_ground():
	if $RayCast_player.is_colliding():
		if ($RayCast_player.get_collider().name) == "angry_tiles":
			player_hit($RayCast_player.get_collider().hp_reduce())


func player_knockback(enemy):
	var pos = self.global_position.x - get_parent().get_node(enemy).global_position.x
	if pos > 0:
		self.global_position.x += 20
	else:
		self.global_position.x -= 20



func _on_wall_jump_timer_timeout():
	wall_jump_complete = true
