extends Area2D

'''   COPY PASTE SECTION BEGIN   '''

#Needed to switch animations          v change this to proper name
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#var plr

#Self-explanatory
@export var max_hp: float = 320.0
var hp: float

#Don't remove this
var health_bar: ProgressBar

#Death Explosion
@onready var explosion = preload("res://scenes/effects/explosion_big.tscn")

#Make sure all functions are here
#If you want a function to occur more often in random just put it in more times
#The order in array is the order of moves in sequence mode
var moves = [
	"move_around",
	"shoot",
	"wait"
]

#Used to cancel boss logic on death
var interrupt = false

func _ready():
	add_to_group("bosses")
	#plr = get_tree().get_nodes_in_group("player")[0]
	body_entered.connect(_on_body_entered)
	
	hp = max_hp
	if health_bar != null:
		health_bar.value = hp/max_hp
	save_pos = position
	
	logic()


enum modes {SEQUENCE, RANDOM, TRUE_RANDOM}
@export var mode = modes.RANDOM
#Handles going through the list of options the boss has
func logic():
	match mode:
		modes.SEQUENCE:
			#Goes through all moves in order
			while not interrupt:
				for i in range(moves.size()):
					if not interrupt:
						await call(moves[i])
		modes.RANDOM:
			#Goes through all moves in random order
			while not interrupt:
				var queue = moves.duplicate()
				for i in range(queue.size()):
					if not interrupt:
						var a = queue.pick_random()
						queue.erase(a)
						await call(a)
		modes.TRUE_RANDOM:
			#Straight up picks a random move every time
			while not interrupt:
				await call(moves.pick_random())
				
				
#Hits the player if they walk into the boss
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()

#Call this from player bullet script
func get_hit():
	if not interrupt:
		hp -= 1
		if health_bar != null:
			health_bar.value = hp/max_hp
		if hp <= 0:
			health_bar.value = 0
			interrupt = true
			await spawn_explosions()
			queue_free()
		
func spawn_explosions():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	for i in range(10):
		var e = explosion.instantiate()
		e.position = Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
		add_child(e)
		await await get_tree().create_timer(0.2 - i*0.01).timeout
'''   COPY PASTE SECTION END  '''

#Example movement function
var save_pos
func move_around():
	for i in range(360):
		if interrupt:
			break
		var angle = (i + 270) * TAU / 360
		position = save_pos + Vector2(sin(angle), cos(angle)-1) * 50.0
		if cos(angle) < 0:
			anim.animation = "move_left"
		elif cos(angle) > 0:
			anim.animation = "move_right"
		await get_tree().create_timer(0.005).timeout
	for i in range(360):
		if interrupt:
			break
		var angle = (i + 270) * TAU / 360
		position = save_pos + Vector2(-sin(angle), cos(angle)-1) * 50.0 - Vector2(100,0)
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
