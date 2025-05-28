extends Area2D

class_name Boss

#Self-explanatory
@export var max_hp: float = 320.0
var hp: float

#Don't remove this
var health_bar: ProgressBar

#Death Explosion
@onready var explosion = preload("res://scenes/effects/explosion_big.tscn")

#Leave empty for automatic detection
@export var moves: Array[String]
@export var background_moves: Array[String]


#Used to cancel boss logic on death
var interrupt = false
var end = false

#If you add any moves to base class add them here
var not_moves = [
	"_ready",
	"logic",
	"_on_body_entered",
	"get_hit",
	"spawn_explosions",
	"flash",
	"points_on_circle"
]


@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
var shader_material: ShaderMaterial

func _ready():
	shader_material = sprite.material as ShaderMaterial
	
	add_to_group("bosses")
	
	if moves.is_empty():
		var a = get_script().get_script_method_list()
		moves.clear()
		for i in a:
			if i.name.ends_with("_stage"):
				moves.append(i.name)
			if i.name.ends_with("_background"):
				background_moves.append(i.name)
		
	body_entered.connect(_on_body_entered)
	
	hp = max_hp
	if health_bar != null:
		health_bar.value = hp/max_hp
	
	logic()


enum modes {SEQUENCE, RANDOM, TRUE_RANDOM}
@export var mode = modes.RANDOM
#Handles going through the list of options the boss has
func logic():
	if moves.is_empty():
		print("BOSS LOGIC ERROR: Boss has no moves!")
		return
	
	call("background_logic")
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

func background_logic():
	while not interrupt:
		await call(background_moves.pick_random())
				
#Hits the player if they walk into the boss
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()

#Call this from player bullet script
var can_get_hit = true;
func get_hit(damage):
	if can_get_hit:
		if not interrupt:
			hp -= damage
			if health_bar != null:
				health_bar.value = hp/max_hp
			if hp <= 0:
				can_get_hit = false
				get_tree().get_nodes_in_group("player")[0].ability_charge = 100
				health_bar.value = 0
				interrupt = true
				get_node("/root/Main/Debug-UI").enemies += 1
				await spawn_explosions()
				queue_free()
			elif not flashing:
				flash()
		
func spawn_explosions():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	for i in range(10):
		var e = explosion.instantiate()
		e.position = Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
		add_child(e)
		await await get_tree().create_timer(0.2 - i*0.01).timeout
		
var flashing = false
func flash():
	if shader_material:
		flashing = true
		var i = 1.0
		shader_material.set_shader_parameter("level", i)
		await get_tree().create_timer(0.1).timeout
		for j in range(10):
			shader_material.set_shader_parameter("level", i)
			i *= 0.8
			await get_tree().create_timer(0.01).timeout
		shader_material.set_shader_parameter("level", 0)
		flashing = false
