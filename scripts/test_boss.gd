extends Boss

#Needed to switch animations  
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#Waits for 2 seconds
func wait_stage():
	anim.animation = "idle"
	await get_tree().create_timer(2).timeout

func wait_background():
	await get_tree().create_timer(1).timeout

#Example movement function
func move_stage():
	for i in range(180):
		if interrupt:
			break
		var angle = (i + 135) * TAU / 180
		position = Vector2(640,250) + Vector2(sin(angle), cos(angle)-1) * 50.0
		if cos(angle) < 0:
			anim.animation = "move_left"
		elif cos(angle) > 0:
			anim.animation = "move_right"
		await get_tree().create_timer(0.01).timeout
	for i in range(180):
		if interrupt:
			break
		var angle = (i + 135) * TAU / 180
		position = Vector2(640,250) + Vector2(-sin(angle), cos(angle)-1) * 50.0 - Vector2(100,0)
		if cos(angle) > 0:
			anim.animation = "move_left"
		elif cos(angle) < 0:
			anim.animation = "move_right"
		await get_tree().create_timer(0.01).timeout

#Example shooting function
@onready var bullet = preload("res://scenes/bullets/enemy_bullet_basic_shoot.tscn")
@onready var bullet_green = preload("res://scenes/bullets/enemy_bullet_basic_shoot_green.tscn")

func shoot_stage():
	anim.animation = "cast"
	for j in range(6):
		if interrupt:
			break
		for i in range(32):
			var b = bullet.instantiate()
			b.position = position
			var angle = i * TAU / 32
			b.dir = Vector2(sin(angle), cos(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.5).timeout



func second_stage():
	await move_stage()
	con_spiral()
	await spiral_moving()

func con_spiral():	
	anim.animation = "cast"
	for j in range(15):
		if interrupt:
			break
		for i in range(4):
			var b = bullet_green.instantiate()
			b.position = position
			var angle_offset = deg_to_rad(-25 + j * 20 + i * 4)
			var angle = angle_offset
			b.dir = Vector2(cos(angle), sin(angle)) * 300.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
			await get_tree().create_timer(0.05).timeout

func spiral_moving():
	anim.animation = "cast"
	for j in range(10):
		if interrupt:
			break
		for i in range(20):
			var b = bullet.instantiate()
			b.position = position
			var angle = j + i * TAU / 20
			b.dir = Vector2(sin(angle), cos(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.3).timeout
