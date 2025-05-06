extends CharacterBody2D
class_name PlayerControler

@export var speed = 200
@export var focus = 0.7

var enabled = true

var items: Dictionary

var screen_size # Size of the game window.

func _ready():
	get_node("./Sprite-focus").visible = false
	add_to_group("player")
	screen_size = get_viewport_rect().size

var vector = Vector2(0, 0)
var last_vector = Vector2(0, 0)

func get_input(delta: float):
	if can_get_hit == false:
		vector.x = 0
		vector.y = -1
		if position.y < screen_size.y * 0.8:
			can_get_hit = true
	#var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	else:
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
	
	if Input.is_action_pressed("ui_sneak"):
		velocity *= focus

	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if Input.is_action_pressed("ui_shoot"):
		if items.get("ShootSpeed") != null:
			get_node("Player_basic_spawner").spawn(items["ShootSpeed"]);
		else:
			get_node("Player_basic_spawner").spawn(0);


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_sneak"):
		get_node("./Sprite-focus").visible = true
	else:
		get_node("./Sprite-focus").visible = false

var can_get_hit = true

var maxHp = 20
var hp = 20
func reset_hp():
	if items.get("HpBoost") != null:
		hp = maxHp + (1 * items["HpBoost"])
	else:
		hp = maxHp

func hit():
	if can_get_hit:
		print("Player got hit")
		respawn()
		hp -= 1
		if hp <= 0:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
		#if items.get("BlinkExtend") != null:
		#	await get_tree().create_timer(0.5 * (1 + items["BlinkExtend"] * 0.5)).timeout
		#else:
		#	await get_tree().create_timer(0.5).timeout
		#can_get_hit = true

func respawn():
	can_get_hit = false
	position.x = screen_size.x / 2
	position.y = screen_size.y
	for node in get_tree().get_nodes_in_group("bullets"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("bullet"):
		node.queue_free()

func _physics_process(delta: float):
	screen_size = get_viewport_rect().size
	if enabled:
		get_input(delta)
		move_and_slide()
