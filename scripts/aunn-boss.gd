extends Boss

#Needed to switch animations  
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var plr: Node

#Waits for 2 seconds
func wait():
	anim.animation = "idle"
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(1).timeout
	
func con_wait():
	anim.animation = "idle"
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(2).timeout
	
#Example movement function
#func move_around():
#	for i in range(180):
#		if interrupt:
#			break
#		var angle = (i + 135) * TAU / 180
#		position = Vector2(640,250) + Vector2(sin(angle), cos(angle)-1) * 50.0
#		if cos(angle) < 0:
#			anim.animation = "move_left"
#		elif cos(angle) > 0:
#			anim.animation = "move_right"
#		await get_tree().create_timer(0.01).timeout
#	for i in range(180):
#		if interrupt:
#			break
#		var angle = (i + 135) * TAU / 180
#		position = Vector2(640,250) + Vector2(-sin(angle), cos(angle)-1) * 50.0 - Vector2(100,0)
#		if cos(angle) > 0:
#			anim.animation = "move_left"
#		elif cos(angle) < 0:
#			anim.animation = "move_right"
#		await get_tree().create_timer(0.01).timeout

#Example shooting function
@onready var bullet_green = preload("res://scenes/bullets/enemy_bullet_basic_shoot_green.tscn")
@onready var bullet_yellow = preload("res://scenes/bullets/enemy_bullet_basic_shoot_yello.tscn")
@onready var bullet_red = preload("res://scenes/bullets/enemy_bullet_basic_shoot_red.tscn")
@onready var bullet = preload("res://scenes/bullets/enemy_bullet_basic_shoot.tscn")
func con_spiral():
	anim.animation = "cast"
	#var angle_main = (plr.global_position - global_position).angle()

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
		
	
