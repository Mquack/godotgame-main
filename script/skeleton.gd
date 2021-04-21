extends KinematicBody2D

const GRAVITY = 10
const SPEED = 60
const HUNT_SPEED = 100

const TYPE = "ENEMY"
const BOUNCEABLE = true

const FLOOR = Vector2(0, -1)
var velocity = Vector2()

var direction = -1
var direction2 = 0

var old_x

var is_dead = false
var is_attacking = false
var attack_area = false
var rate_attack = 0.5
var can_attack = true
var follow_state = false
var follow_direction = Vector2()
var distance
var follow_distance = 200
var stunned = false

var hp = 10
const max_health = 10

onready var health_bar = $HealthBar/HealthBar
onready var health_under = $HealthBar/HealthBar_under
onready var update_health = $HealthBar/UpdateHealth

func _ready():
	pass#$AnimatedSprite_health.play("hp_array[3]")


func _physics_process(delta):
	head_bonk()
	#avoid_ledge()
	#stun_it(3)
	if !stunned:
		if !follow_target_state():
			if !is_dead and !is_attacking:
				if $RayCast2D.is_colliding():
					velocity.x = SPEED * direction
					
					if direction == 1:
						$AnimatedSprite.flip_h = true
					else: 
						$AnimatedSprite.flip_h = false
						
					$AnimatedSprite.play("new_walk")

				velocity.y += GRAVITY

				velocity = move_and_slide(velocity, FLOOR)

			#check for collision with wall
			if is_on_wall():
				direction *= -1
				$AnimatedSprite.flip_h = true
				$RayCast2D.position.x *= -1
					
				
			#check if there is gound underneath
			if $RayCast2D.is_colliding() == false:
				direction *= -1
				$RayCast2D.position.x *= -1
				$RayCast2D.cast_to.x *= -1
				$AnimatedSprite.flip_h = true
			"""
			if $RayCast2_sword.is_colliding() or $RayCast2_sword1.is_colliding() or $RayCast2_sword2.is_colliding():
				if $RayCast2_sword.get_collider().name == "player":
					attack_player()
					print("attack0")
				elif $RayCast2_sword1.get_collider().name == "player":
					attack_player()
					print("attack1")
				elif $RayCast2_sword2.get_collider().name == "player":
					attack_player()
					print("attack2")"""
		else:
			follow_target()
			
	
	if (direction * abs($RayCast2_sword.cast_to.x)) != $RayCast2_sword.cast_to.x:
		$RayCast2_sword.cast_to.x *= -1
	if (direction * abs($RayCast2D.position.x)) != $RayCast2D.position.x:
		$RayCast2D.position.x *= -1
		
func stun_it(time_to_stun):
	#if !stunned:
	$AnimatedSprite.play("stunned")
	stun_timer(time_to_stun)
		
#sleep timer with time and a boolean to flipp(false -> true -> false)
func stun_timer(time):
	stunned = true
	yield(get_tree().create_timer(time), "timeout")
	stunned = false

func head_bonk():
	if $RayCast_head.is_colliding():
		if $RayCast_head.get_collider().name == "player":
			if !stunned:
				$AnimatedSprite.play("stunned")
				stun_timer(3.0)
		
func follow_target():
	if !is_dead:
		var direction_temp = (abs(get_node("/root/StageOne/player").global_position.x) - abs(self.global_position.x))
		if direction_temp > 0:
			direction = 1
		else:
			direction = -1
		
		if !is_dead and !is_attacking:
				if $RayCast2D.is_colliding():
					velocity.x = HUNT_SPEED * direction
					
					if direction == 1:
						$AnimatedSprite.flip_h = true
					else: 
						$AnimatedSprite.flip_h = false
						
					$AnimatedSprite.play("new_hunt")
					#$RayCast2_sword.cast_to.x *= direction

				velocity.y += GRAVITY

				velocity = move_and_slide(velocity, FLOOR)
				
		# stand still if stuck on something
		if !is_attacking and abs(velocity.x) < 1:
			$AnimatedSprite.play("new_hunt_idle")

		if $RayCast2_sword.is_colliding():
			if $RayCast2_sword.get_collider().name == "player":
				print("attack0")
				attack_player()
		elif $RayCast2_sword1.is_colliding():
			if $RayCast2_sword1.get_collider().name == "player":
				print("attack1")
				attack_player()
		elif $RayCast2_sword2.is_colliding():
			if $RayCast2_sword2.get_collider().name == "player":
				print("attack2")
				attack_player()


func avoid_ledge():
	if follow_state:
		if $RayCast2D.is_colliding() == false:
			follow_distance = 0
			old_x = self.global_position.x
			return true


func follow_target_state():
	follow_direction = get_node("/root/StageOne/player").global_position - self.global_position
	distance = sqrt(follow_direction.x * follow_direction.x + follow_direction.y * follow_direction.y)
	#print(self.global_position.x)
	if avoid_ledge():
		return
	elif old_x:
		if old_x + 100 > (self.global_position.x) or old_x - 100 < (self.global_position.x):
			if follow_distance < 200:
				follow_distance += 2
		
	if distance < follow_distance and !get_parent().get_node("player").is_dead:
		follow_state = true
	else:
		follow_state = false
		
	return follow_state


func _on_Timer_timeout():
	queue_free()


func _on_AnimatedSprite_animation_finished():
	is_attacking = false
	#TODO check if raycast still connecting- if so, damage player?


func attack_player():
	#check if collision is player for attack
	if can_attack and !is_dead and !get_parent().get_node("player").is_dead:
		can_attack = false
		is_attacking = true
		$AnimatedSprite.play("new_attack")
		yield(get_tree().create_timer(rate_attack), "timeout")
		get_node("/root/StageOne/player").player_hit()
		can_attack = true


func _on_A2D_head_area_entered(area):
	#print("head HIT by ", area.name)
	if area.name == "aimed_carrot":
		dead(2)


func _on_A2D_body_area_entered(area):
	#print("body HIT by ", area.name)
	if area.name == "aimed_carrot":
		dead(1)


func _on_UpdateHealth_tween_completed(object, key):
	$HealthBar/HP_display.visible = false


func on_health_updated(hp):
	health_bar.value = hp
	#health_under.value = hp
	update_health.interpolate_property(health_under, "value", health_under.value, hp, 1, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	update_health.start()


func dead(hitpoints):
	#$HealthBar/HP_display.set_text(str(hitpoints * -1))
	#$HealthBar/HP_display.visible = true
	if hp <= hitpoints:
		is_dead = true
		velocity = Vector2(0, 0)
		hp = 0
		on_health_updated(hp)
		$AnimatedSprite.set_z_index(-1)
		#$AnimatedSprite_health.visible = false
		$AnimatedSprite.play("new_dead")
		$CollisionShape2D.call_deferred("set_disabled", true)
		$A2D_body/CollisionShape2D.call_deferred("set_disabled", true)
		$A2D_head/CollisionShape2D_head.call_deferred("set_disabled", true)
		$RayCast_head.enabled = false
		$Timer.start()
	else:
		knockback()
		is_attacking = true
		$AnimatedSprite.play("new_damage")
		hp -= hitpoints
		on_health_updated(hp)


func knockback():
	var pos = self.global_position.x - get_parent().get_node("player").global_position.x
	if pos > 0:
		self.global_position.x += 25
	else:
		self.global_position.x -= 25
