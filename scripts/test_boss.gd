extends Boss

#Needed to switch animations  
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#Waits for 2 seconds
func wait_stage():
	anim.animation = "idle"
	await get_tree().create_timer(2).timeout
	
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
func shoot_stage():
	anim.animation = "cast"
	for j in range(4):
		if interrupt:
			break
		for i in range(32):
			var b = bullet.instantiate()
			b.position = position
			var angle = i * TAU / 32
			b.dir = Vector2(sin(angle), cos(angle)) * 200.0
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(b)
		await get_tree().create_timer(0.5).timeout
