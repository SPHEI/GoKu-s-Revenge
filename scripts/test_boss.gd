extends Boss

#Needed to switch animations  
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#Example movement function
func move_around():
	for i in range(360):
		if interrupt:
			break
		var angle = (i + 270) * TAU / 360
		position = Vector2(1000,250) + Vector2(sin(angle), cos(angle)-1) * 50.0
		if cos(angle) < 0:
			anim.animation = "move_left"
		elif cos(angle) > 0:
			anim.animation = "move_right"
		await get_tree().create_timer(0.005).timeout
	for i in range(360):
		if interrupt:
			break
		var angle = (i + 270) * TAU / 360
		position = Vector2(1000,250) + Vector2(-sin(angle), cos(angle)-1) * 50.0 - Vector2(100,0)
		if cos(angle) > 0:
			anim.animation = "move_left"
		elif cos(angle) < 0:
			anim.animation = "move_right"
		await get_tree().create_timer(0.005).timeout

#Waits for 2 seconds
func wait():
	anim.animation = "idle"
	await get_tree().create_timer(2).timeout

#Example shooting function
@onready var bullet = preload("res://scenes/bullets/enemy_bullet_basic.tscn")
func shoot():
	anim.animation = "cast"
	for j in range(4):
		if interrupt:
			break
		for i in range(32):
			var b = bullet.instantiate()
			b.position = position
			var angle = i * TAU / 32
			b.dir = Vector2(sin(angle), cos(angle)) * 200.0
			get_tree().root.add_child(b)
		await get_tree().create_timer(0.5).timeout
