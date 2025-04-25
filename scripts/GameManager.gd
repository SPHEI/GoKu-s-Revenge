extends Node2D

#Counts how many objects are in the scene right now
var stuffSpawned = 0

#Reference to levelManager
@onready var level_manager: Node3D = $"3DEnviorment"

#Add new bullets/enemies here
@onready var bullet_basic = preload("res://scenes/enemy_bullet_basic.tscn")

func _ready() -> void:
	stage_1()
func _process(_delta: float) -> void:
	pass
	
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
	await pattern_back_and_foth(3)
	await get_tree().create_timer(2.0).timeout
	await pattern_fan(1)
	await waitUntilClear()
	level_manager.nextLevel()
	
#PATTERN SECTION
func pattern_line_horiz_basic(offset: float, dir: Vector2):
	for i in range(20):
		spawnBullet(bullet_basic, Vector2(100.0 * i + offset,-4.0), dir)
func pattern_back_and_foth(repetitions: int):
	for j in range(repetitions):
		for i in range(10):
			pattern_line_horiz_basic(20.0 * i, Vector2(0.0,100.0))
			await get_tree().create_timer(0.2).timeout
		for i in range(10):
			pattern_line_horiz_basic(200.0 - 20.0 * i, Vector2(0.0,100.0))
			await get_tree().create_timer(0.2).timeout
func pattern_fan(repetitions: int):
	for j in range(repetitions):
		for i in range(30):
			pattern_line_horiz_basic(0.0, Vector2(1.0 * i,50.0))
			await get_tree().create_timer(0.2).timeout
