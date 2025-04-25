extends Node2D

#Counts how many objects are in the scene right now
var stuffSpawned = 0

#Reference to levelManager
@onready var level_manager: Node3D = $"3DEnviorment"

#Add new bullets here
@onready var bullet_basic = preload("res://scenes/bullets/enemy_bullet_basic.tscn")

#Add new enemies here
@onready var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")

func _ready() -> void:
	stage_1()
func _process(_delta: float) -> void:
	pass
	
func spawnEnemy(type: Resource, pos: Vector2):
	var b = type.instantiate()
	b.position = pos
	add_child(b)
	stuffSpawned += 1
	
func spawnBullet(type: Resource, pos: Vector2, dir: Vector2):
	var b = type.instantiate()
	b.position = pos
	b.dir = dir
	add_child(b)
	stuffSpawned += 1

func waitUntilClear():
	while stuffSpawned > 0:
		await get_tree().create_timer(0.2).timeout
		
#STAGES SECTION
func stage_1():
	await enemy_pattern_line_horiz_kamikaze(0)
	await waitUntilClear()
	
	await bullet_pattern_back_and_foth(3)
	await get_tree().create_timer(2.0).timeout
	
	await bullet_pattern_fan(1)
	await waitUntilClear()
	
	await level_manager.nextLevel()
	stage_2()

func stage_2():
	await enemy_pattern_line_horiz_kamikaze(0)
	await get_tree().create_timer(2.0).timeout
	await enemy_pattern_line_horiz_kamikaze(0)
	await waitUntilClear()
	
	await bullet_pattern_fan(1)
	await get_tree().create_timer(1.0).timeout
	await bullet_pattern_fan(1)
	await waitUntilClear()
	
	await level_manager.nextLevel()
	
#BULLET PATTERN SECTION
func bullet_pattern_line_horiz_basic(offset: float, dir: Vector2):
	for i in range(20):
		spawnBullet(bullet_basic, Vector2(100.0 * i + offset,-4.0), dir)
func bullet_pattern_back_and_foth(repetitions: int):
	for j in range(repetitions):
		for i in range(10):
			bullet_pattern_line_horiz_basic(20.0 * i, Vector2(0.0,100.0))
			await get_tree().create_timer(0.2).timeout
		for i in range(10):
			bullet_pattern_line_horiz_basic(200.0 - 20.0 * i, Vector2(0.0,100.0))
			await get_tree().create_timer(0.2).timeout
func bullet_pattern_fan(repetitions: int):
	for j in range(repetitions):
		for i in range(30):
			bullet_pattern_line_horiz_basic(0.0, Vector2(1.0 * i,50.0))
			await get_tree().create_timer(0.2).timeout

#ENEMY PATTERN SECTION
func enemy_pattern_line_horiz_kamikaze(offset: float):
	for i in range(10):
		spawnEnemy(kamikaze, Vector2(200.0 * i + offset,-4.0))
