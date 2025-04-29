extends CharacterBody2D
class_name PlayerControler

@export var speed = 200
var vector = Vector2(0, 0)
var last_vector = Vector2(0, 0)

#@onready var scene_bullet = preload("res://bullet.tscn")


'''
ITEMS:
SpeedBoost: Boosts Movement speed by 10% (+10 per stack)
BlinkExtend: Extends after-hit invincibility by 50% (+50 per stack)
'''
var items: Dictionary

var can_attack = true
var screen_size # Size of the game window.

func _ready():
	add_to_group("player")
	screen_size = get_viewport_rect().size

func get_input(delta: float):
	#var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_right"):
		vector.x = -last_vector.x
	elif Input.is_action_pressed("ui_left"):
		vector.x = -1
		last_vector.x = -1
	elif Input.is_action_pressed("ui_right"):
		vector.x = 1
		last_vector.x = 1
	else:
		vector.x = 0
		last_vector.x = 0
	
	if Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_down"):
			vector.y = -last_vector.y
	elif  Input.is_action_pressed("ui_up"):
		vector.y = -1
		last_vector.y = -1
	elif Input.is_action_pressed("ui_down"):
		vector.y = 1
		last_vector.y = 1
	else:
		vector.y = 0
		last_vector.y = 0	
	
	if vector.x != 0 && vector.y != 0:
		vector.x *= 1/sqrt(2)
		vector.y *= 1/sqrt(2)
	
	if items.get("SpeedBoost") != null:
		velocity = vector * (speed * (1 + items["SpeedBoost"]*0.1))
	else:
		velocity = vector * speed
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	#if Input.is_action_pressed("ui_shoot") && can_attack:
	#	shoot()
	#	can_attack = false
	#	get_tree().create_timer(0.1).timeout.connect(func(): can_attack = true)

var can_get_hit = true
func hit():
	if can_get_hit:
		print("Player got hit")
		can_get_hit = false
		if items.get("BlinkExtend") != null:
			await get_tree().create_timer(0.5 * (1 + items["BlinkExtend"] * 0.5)).timeout
		else:
			await get_tree().create_timer(0.5).timeout
		can_get_hit = true


#func shoot():
#	var bullet_1 = scene_bullet.instantiate()
#	bullet_1.position = $Spawn_1.global_position
#	owner.add_child(bullet_1)
#	
#	var bullet_2 = scene_bullet.instantiate()
#	bullet_2.position = $Spawn_2.global_position
#	owner.add_child(bullet_2)
#	
#	get_node("/root/Main/Control/BulletsLabel").text = str(owner.get_child_count() - 1)
#
#	
#	pass


func _physics_process(delta: float):
	get_input(delta)
	move_and_slide()
