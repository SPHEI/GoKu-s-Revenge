extends Boss

#Needed to switch animations  
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var plr: Node

#Waits for 2 seconds
func wait_stage():
	anim.animation = "idle"
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(1).timeout

func first_stage():
	await call("con_non_spell")
	
func second_stage():
	call("con_spiral")
	await call("con_non_spell")

#Example shooting function
@onready var bullet_green = preload("res://scenes/bullets/enemy_bullet_basic_shoot_green.tscn")
@onready var bullet_yellow = preload("res://scenes/bullets/enemy_bullet_basic_shoot_yello.tscn")
@onready var bullet_red = preload("res://scenes/bullets/enemy_bullet_basic_shoot_red.tscn")
@onready var bullet = preload("res://scenes/bullets/enemy_bullet_basic_shoot.tscn")
@onready var bullet_aunn = preload("res://scenes/bullets/enemy_bullet_aunn_shoot_green.tscn")

func con_non_spell():
	var amount = 20
	var radius = 100
	var time = 6
	var origin = points_on_circle(global_position, 10, amount)
	var target = points_on_circle(global_position, 10 + radius, amount)
	for j in range(time):
		for i in range(amount):
			var b = bullet_aunn.instantiate()
			b.position = origin[i]
			b.target_position = target[i]  # Now valid because bullet_aunn.gd defines this property
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(2).timeout

func con_spiral():
	anim.animation = "cast"
	
	for j in range(50):
		if interrupt:
			break
		for i in range(4):
			var b = bullet_yellow.instantiate()
			b.position = position
			var angle_offset = deg_to_rad(-25 + j * 20 + i * 4)
			var angle = angle_offset
			b.dir = Vector2(cos(angle), sin(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
			await get_tree().create_timer(0.05).timeout


func points_on_circle(center: Vector2, radius: float, count: int) -> Array:
	var points = []
	for i in range(count):
		var angle = (2.0 * PI / count) * i
		var point = Vector2(
			center.x + radius * cos(angle),
			center.y + radius * sin(angle)
		)
		points.append(point)
	return points



func con_shoot():
	anim.animation = "cast"
	for j in range(80):
		if interrupt:
			break
		for i in range(15):
			var b = bullet_green.instantiate()
			b.position = position
			var angle = j + i * TAU / 15
			b.dir = Vector2(sin(angle), cos(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.3).timeout
		
func shoot_at_player():
	anim.animation = "cast"
	var angle_main = (plr.global_position - global_position).angle()

	for j in range(15):
		if interrupt:
			break
		for i in range(6):
			var b = bullet.instantiate()
			b.position = position
			var angle_offset = deg_to_rad(-25 + i * 10)
			var angle = angle_main + angle_offset
			b.dir = Vector2(cos(angle), sin(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.3).timeout
		
	
