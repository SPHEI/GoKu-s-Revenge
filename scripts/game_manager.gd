extends Node2D

#Counts how many objects are in the scene right now
var stuff_spawned = 0

#Reference to levelManager
@onready var level_manager: Node3D = $"3DEnviorment"

#Add new bullets here
@onready var bullet_basic = preload("res://scenes/bullets/enemy_bullet_basic.tscn")

#Add new enemies here
@onready var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")

@export var ui: Control = null;
var win_text: Label = null;

func _ready() -> void:
	for l in ui.get_children():
		if l.name == "WinText":
			win_text = l;
			win_text.text = ""
	stage_1()
func _process(_delta: float) -> void:
	pass
	
func spawn_enemy(type: Resource, pos: Vector2):
	var b = type.instantiate()
	b.position = pos
	add_child(b)
	stuff_spawned += 1
	
func spawn_bullet(type: Resource, pos: Vector2, dir: Vector2):
	var b = type.instantiate()
	b.position = pos
	b.dir = dir
	add_child(b)
	stuff_spawned += 1

func wait_until_clear():
	while stuff_spawned > 0:
		await get_tree().create_timer(0.2).timeout
		
#STAGES SECTION
func stage_1():
	await enemy_pattern_line_horiz_kamikaze(0)
	await wait_until_clear()
	
	await bullet_pattern_back_and_foth(3)
	await get_tree().create_timer(2.0).timeout
	
	await bullet_pattern_fan(1)
	await wait_until_clear()
	
	await level_manager.next_level()
	stage_2()

func stage_2():
	await enemy_pattern_line_horiz_kamikaze(0)
	await get_tree().create_timer(2.0).timeout
	await enemy_pattern_line_horiz_kamikaze(0)
	await wait_until_clear()
	
	await bullet_pattern_fan(1)
	await get_tree().create_timer(1.0).timeout
	await bullet_pattern_fan(1)
	await wait_until_clear()
	
	await level_manager.next_level()
	win_game()
	
func win_game():
	print("Player won")
	win_text.text = "You won!"
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
	
	
#BULLET PATTERN SECTION
func bullet_pattern_line_horiz_basic(offset: float, dir: Vector2):
	for i in range(20):
		spawn_bullet(bullet_basic, Vector2(100.0 * i + offset,-4.0), dir)
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
		spawn_enemy(kamikaze, Vector2(200.0 * i + offset,-4.0))
