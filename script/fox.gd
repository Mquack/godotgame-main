extends KinematicBody2D

const GRAVITY = 10
const SPEED = 60
const HUNT_SPEED = 100

const TYPE = "ENEMY"
const BOUNCEABLE = true

const FLOOR = Vector2(0, -1)
var velocity = Vector2()
var MOVE = true

var direction = -1

var old_x

var is_dead = false
var is_attacking = false
var attack_area = false
var rate_attack = 1#0.5
var can_attack = true
var follow_state = false
var follow_direction = Vector2()
var distance
var follow_distance = 150
var stunned = false
var knocked_back = false

var hp = 10
const max_health = 10

onready var health_bar = $HealthBar/HealthBar
onready var health_under = $HealthBar/HealthBar_under
onready var update_health = $HealthBar/UpdateHealth

var knockback_timer



func _ready():
	#pass
	#$AnimatedSprite_health.play("hp_array[3]")
	knockback_timer = Timer.new()
	knockback_timer.set_one_shot(true)
	knockback_timer.set_wait_time(0.75)
	knockback_timer.connect("timeout", self, "_on_knockback_timer_timeout")
	add_child(knockback_timer)

func _physics_process(delta):
	if !follow_target_state():
		if !is_dead:
			if $RayCast2D.is_colliding():
				velocity.x = SPEED * direction
				
				$AniSpr_body.play("walk")
				$AniSpr_feet.play("walk_feet")
				
			velocity.y += GRAVITY
			
			velocity = move_and_slide(velocity, FLOOR)
			
		#check for collision with wall
		if is_on_wall():
			direction *= -1
			
		#check if there is gound underneath
		if $RayCast2D.is_colliding() == false:
			direction *= -1
		
	elif knocked_back:
		velocity = move_and_slide(velocity, FLOOR)
	else:
		follow_target()
		
	flip_char()


func flip_char():
	if direction == 1:
		$AniSpr_body.flip_h = true
		$AniSpr_feet.flip_h = true
	else:
		$AniSpr_body.flip_h = false
		$AniSpr_feet.flip_h = false
		
	if (direction * abs($RayCast_sword0.cast_to.x)) != $RayCast_sword0.cast_to.x:
		$RayCast_sword0.cast_to.x *= -1
		$RayCast_sword1.cast_to.x *= -1
		$RayCast_sword2.cast_to.x *= -1
		
	if (direction * abs($RayCast2D.position.x)) != $RayCast2D.position.x:
		$RayCast2D.position.x *= -1
		
	if (direction * abs($Position2D.position.x)) != $Position2D.position.x:
		$Position2D.position.x *= -1
		
		
func follow_target():
	if !is_dead:
		var direction_temp = (abs(get_node("/root/StageOne/player").global_position.x) - abs($Position2D.global_position.x))
		var dir_turn = (abs(get_node("/root/StageOne/player").global_position.x) - abs(self.global_position.x))
#		if direction_temp > 1:
#			MOVE = true
#		elif direction_temp < 1:
#			MOVE = true
		if abs(direction_temp) > 10:
			MOVE = true
		else:
			MOVE = false
			
		if dir_turn > 10:
			direction = 1
		elif dir_turn < -10:
			direction = -1
			
		if !is_dead and !is_attacking:
				if $RayCast2D.is_colliding():
					if MOVE:
						velocity.x = HUNT_SPEED * direction
						$AniSpr_body.play("attack_run")
						$AniSpr_feet.play("attack_run_feet")
					else:
						velocity.x = 0
						$AniSpr_feet.play("idle_feet")
				
				velocity.y += GRAVITY
				
				velocity = move_and_slide(velocity, FLOOR)
				
		# stand still if stuck on something
		if !is_attacking and abs(velocity.x) < 1:
			$AniSpr_body.play("attack_run")
			
		if $RayCast_sword0.is_colliding():
			if $RayCast_sword0.get_collider().name == "player":
				attack_player(0)
		elif $RayCast_sword1.is_colliding():
			if $RayCast_sword1.get_collider().name == "player":
				attack_player(1)
		elif $RayCast_sword2.is_colliding():
			if $RayCast_sword2.get_collider().name == "player":
				attack_player(2)
				
		MOVE = true

func avoid_ledge_and_wall():
	if follow_state:
		if $RayCast2D.is_colliding() == false or is_on_wall():
			if is_on_wall():
				for i in range(get_slide_count()):
					if (get_slide_collision(i).collider.name) == "player":
						return false
			follow_distance = 0
			old_x = self.global_position.x
			return true


func follow_target_state():
	follow_direction = get_node("/root/StageOne/player").global_position - self.global_position
	distance = sqrt(follow_direction.x * follow_direction.x + follow_direction.y * follow_direction.y)
	if avoid_ledge_and_wall():
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

#when animation finished check for collision with player and do damage
func _on_AnimatedSprite_animation_finished():
#	if is_attacking:
#		if $RayCast_sword0.is_colliding():
#			if $RayCast_sword0.get_collider().name == "player":
#				get_node("/root/StageOne/player").player_hit()
#				get_node("/root/StageOne/player").player_knockback(self.name)
#		elif $RayCast_sword1.is_colliding():
#			if $RayCast_sword1.get_collider().name == "player":
#				get_node("/root/StageOne/player").player_hit()
#				get_node("/root/StageOne/player").player_knockback(self.name)
#		elif $RayCast_sword2.is_colliding():
#			if $RayCast_sword2.get_collider().name == "player":
#				get_node("/root/StageOne/player").player_hit()
#				get_node("/root/StageOne/player").player_knockback(self.name)
	is_attacking = false
	if !is_dead:
		$AniSpr_feet.visible = true

#if attacking is possible, play animation and control attack rate and bools
func attack_player(dir:int = 1):
	#check if collision is player for attack
	if can_attack and !is_dead and !get_parent().get_node("player").is_dead:
		can_attack = false
		is_attacking = true
		if dir == 0:
			$AniSpr_body.play("attack0")
		elif dir == 1:
			$AniSpr_body.play("attack1")
		elif dir == 2:
			$AniSpr_body.play("attack2")
		get_node("/root/StageOne/player").player_hit()
		get_node("/root/StageOne/player").player_knockback(self.name)
		yield(get_tree().create_timer(rate_attack), "timeout")
		can_attack = true


func _on_A2D_head_area_entered(area):
	if area.name == "aimed_carrot":
		dead(2)


func _on_A2D_body_area_entered(area):
	if area.name == "aimed_carrot":
		dead(1)


func _on_UpdateHealth_tween_completed(object, key):
	$HealthBar/HP_display.visible = false


func on_health_updated(hp):
	health_bar.value = hp
	update_health.interpolate_property(health_under, "value", health_under.value, hp, 1, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	update_health.start()


func dead(hitpoints):
	#$HealthBar/HP_display.set_text(str(hitpoints * -1))
	#$HealthBar/HP_display.visible = true
	print("hurt by hitpoints, ", hitpoints)
	if hp <= hitpoints:
		is_dead = true
		velocity = Vector2(0, 0)
		hp = 0
		on_health_updated(hp)
		$AniSpr_body.set_z_index(-1)
		$AniSpr_feet.set_z_index(-1)
		$AniSpr_feet.visible = false		
		$AniSpr_body.play("death")
		$CollisionShape2D.call_deferred("set_disabled", true)
		$A2D_body/CollisionShape2D.call_deferred("set_disabled", true)
		$A2D_head/CollisionShape2D.call_deferred("set_disabled", true)
		$Timer.start()
	else:
		knockback()
		is_attacking = true
		$AniSpr_feet.visible = false
		$AniSpr_body.play("hurt")
		hp -= hitpoints
		on_health_updated(hp)


func knockback():
	if !knocked_back:
		knocked_back = true
		#direction *= -1
		velocity.x = SPEED * (direction * -1)
		knockback_timer.start()
		#velocity.y += GRAVITY
	#velocity = move_and_slide(velocity, FLOOR)
	
	
#	var pos = self.global_position.x - get_parent().get_node("player").global_position.x
#	if pos > 0:
#		self.global_position.x += 20
#	else:
#		self.global_position.x -= 20


func _on_knockback_timer_timeout():
	knocked_back = false
