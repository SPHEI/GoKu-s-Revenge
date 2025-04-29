extends CharacterBody2D
class_name PlayerControler

@export var speed = 200
var vector = Vector2(0, 0)
var last_vector = Vector2(0, 0)

#@onready var scene_bullet = preload("res://bullet.tscn")

var enabled = true

'''
ITEMS:
SpeedBoost: Boosts Movement speed by 10% (+10 per stack)
BlinkExtend: Extends after-hit invincibility by 50% (+50 per stack)
ShootSpeed: Boosts shooting speed by 50% (+50% per stack)
AbilitySpeed: Boosts the charge rate of ability by +1% (+1 per stack) every time charge is gained. TODO
HpBoost: +1 maxHp per stack
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
	if Input.is_action_pressed("ui_sneak") and velocity.length() > 100:
		velocity = velocity.normalized() * 100
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if Input.is_action_pressed("ui_shoot") && can_attack:
		shoot()
		can_attack = false
		if items.get("ShootSpeed") != null:
			get_tree().create_timer(0.1 * (pow(.5,items["ShootSpeed"]))).timeout.connect(func(): can_attack = true)
		else:
			get_tree().create_timer(0.1).timeout.connect(func(): can_attack = true)

var can_get_hit = true

var maxHp = 3
var hp = 3
func reset_hp():
	if items.get("HpBoost") != null:
		hp = maxHp + (1 * items["HpBoost"])
	else:
		hp = maxHp

func hit():
	if can_get_hit:
		print("Player got hit")
		can_get_hit = false
		hp -= 1
		if hp <= 0:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/node_2d.tscn")
		if items.get("BlinkExtend") != null:
			await get_tree().create_timer(0.5 * (1 + items["BlinkExtend"] * 0.5)).timeout
		else:
			await get_tree().create_timer(0.5).timeout
		can_get_hit = true


@onready var bullet_basic = preload("res://scenes/bullets/bullet.tscn")

func shoot():
	var marker_root = get_node("./Player_basic_spawner")
	for marker in marker_root.get_children():
		if marker is Marker2D:
			var bullet_1 = bullet_basic.instantiate()
			bullet_1.position = marker.global_position
			owner.add_child(bullet_1)

func _physics_process(delta: float):
	if enabled:
		get_input(delta)
		move_and_slide()
