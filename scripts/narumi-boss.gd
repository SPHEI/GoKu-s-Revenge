extends Boss

#Needed to switch animations  
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var plr: Node



func wait_background():
	anim.animation = "idle"
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(1).timeout
	
func move_background():
	for i in range(180):
		if interrupt:
			break
		var angle = (i + 135) * TAU / 180
		position = Vector2(640,250) + Vector2(sin(angle), cos(angle)-1) * 50.0
		if cos(angle) < 0:
			if anim.animation != "move_left_loop":
				anim.animation = "move_left"
			if anim.frame == 4:
				anim.animation = "move_left_loop"
		elif cos(angle) > 0:
			if anim.animation != "move_right_loop":
				anim.animation = "move_right"
			if anim.frame == 4:
				anim.animation = "move_right_loop"
		await get_tree().create_timer(0.01).timeout
	for i in range(180):
		if interrupt:
			break
		var angle = (i + 135) * TAU / 180
		position = Vector2(640,250) + Vector2(-sin(angle), cos(angle)-1) * 50.0 - Vector2(100,0)
		if cos(angle) > 0:
			if anim.animation != "move_left_loop":
				anim.animation = "move_left"
				if anim.frame == 4:
					anim.animation = "move_left_loop"
		elif cos(angle) < 0:
			if anim.animation != "move_right_loop":
				anim.animation = "move_right"
				if anim.frame == 4:
					anim.animation = "move_right_loop"
		await get_tree().create_timer(0.01).timeout

func wait_stage():
	anim.animation = "idle"
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(1).timeout
	

func first_stage():
	end = false
	anim.animation = "idle"
	con_shoot()
	await con_non_spell(20, 100)
	end = true
	
func second_stage():
	end = false
	anim.animation = "cast"
	shoot_at_player()
	dan_better(20, 150)
	await dan(30, 100)
	end = true

func third_stage():
	end = false
	anim.animation = "cast"
	con_spiral(1)
	con_spiral(-1)
	await con_shoot()
	end = true

#Example shooting function
@onready var bullet_green = preload("res://scenes/bullets/enemy_bullet_basic_shoot_green.tscn")
@onready var bullet_yellow = preload("res://scenes/bullets/enemy_bullet_basic_shoot_yello.tscn")
@onready var bullet_red = preload("res://scenes/bullets/enemy_bullet_basic_shoot_red.tscn")
@onready var bullet = preload("res://scenes/bullets/enemy_bullet_basic_shoot.tscn")
@onready var bullet_narumi = preload("res://scenes/bullets/enemy_bullet_narumi_shoot_green.tscn")
@onready var bullet_aunn = preload("res://scenes/bullets/enemy_bullet_aunn_shoot_green.tscn")

func con_non_spell( amount , radius):
	var time = 6
	var origin = points_on_circle(global_position, 10, amount)
	var target = points_on_circle(global_position, 10 + radius, amount)
	for j in range(time):
		if interrupt or end:
			break
		for i in range(amount):
			var b = bullet_aunn.instantiate()
			b.position = origin[i]
			b.target_position = target[i]  # Now valid because bullet_aunn.gd defines this property
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(2).timeout

func dan( amount , radius):
	var time = 6
	var origin = points_on_circle(global_position, 10, amount)
	var targets: Array
	targets.append(points_on_circle(global_position, 10 + radius, amount))
	targets.append(points_on_circle(global_position, 10 + radius * 2, amount))
	targets.append(points_on_circle(global_position, 10 + radius * 3, amount))
	for j in range(time):
		if interrupt or end:
			break
		for i in range(amount):
			var b = bullet_aunn.instantiate()
			b.position = origin[i]
			b.target_position = targets[i%3][i]  # Now valid because bullet_aunn.gd defines this property
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(2).timeout
		
func dan_better( amount , radius):
	var time = 6
	var stages = 5
	var origin = points_on_circle(global_position, 10, amount)
	var targets: Array
	for x in range(stages):
		targets.append(points_on_circle(global_position, 10 + radius * x, amount))
	targets.append(points_on_circle(global_position, 10 + radius * 20, amount))	
	stages+=1
	for j in range(time):
		if interrupt or end:
			break
		for i in range(amount):
			var b = bullet_narumi.instantiate()
			b.position = origin[i]
			for x in range(stages):
				if amount <= i + x:
					b.target_position.append(targets[x][i + x - amount])
				else:
					b.target_position.append(targets[x][i + x])
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.5).timeout

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

func con_spiral(dir):	
	anim.animation = "cast"
	for j in range(50):
		if interrupt or end:
			break
		for i in range(4):
			var b = bullet.instantiate()
			b.position = position
			var angle_offset = deg_to_rad(-25 + j * 20 + i * 4)
			var angle = dir * angle_offset
			b.dir = Vector2(cos(angle), sin(angle)) * 300.0
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
		if interrupt or end:
			break
		for i in range(6):
			var b = bullet.instantiate()
			b.position = position
			var angle_offset = deg_to_rad(-25 + i * 10)
			var angle = angle_main + angle_offset
			b.dir = Vector2(cos(angle), sin(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.6).timeout
		
