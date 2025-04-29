extends CharacterBody2D
class_name PlayerControler

@export var speed = 100
var vector = Vector2(0, 0)
var last_vector = Vector2(0, 0)
var manager: Node

#@onready var scene_bullet = preload("res://bullet.tscn")

var can_attack = true
var screen_size # Size of the game window.

func _ready():
	add_to_group("player")
	manager = get_tree().get_nodes_in_group("manager")[0]
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
	
	velocity = vector * speed
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if Input.is_action_pressed("ui_shoot") && can_attack:
		shoot()
		can_attack = false
		get_tree().create_timer(0.1).timeout.connect(func(): can_attack = true)

func hit():
	print("Player got hit")
	manager.reset()

@onready var bullet_basic = preload("res://scenes/bullets/bullet.tscn")
@onready var spawner_basic = preload("res://basic_enemy_spawner.tscn")

func shoot():
	var marker_root = get_node("./Player_basic_spawner")  # Example path
	for marker in marker_root.get_children():
		if marker is Marker2D:
			var bullet_1 = bullet_basic.instantiate()
			bullet_1.position = marker.global_position
			owner.add_child(bullet_1)
	
	
	#var bullet_1 = bullet_basic.instantiate()
	#bullet_1.position = spawner_basic.
	
	#owner.add_child(bullet_1)
	
	#var bullet_2 = bullet_basic.instantiate()
	#bullet_2.position = $Player_basic_spawner/"spawner-2".global_position
	#owner.add_child(bullet_2)
	
	#get_node("/root/Main/Control/BulletsLabel").text = str(owner.get_child_count() - 1)


func _physics_process(delta: float):
	get_input(delta)
	move_and_slide()
