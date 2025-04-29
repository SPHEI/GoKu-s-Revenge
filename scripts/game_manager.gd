extends Node2D

#Counts how many objects are in the scene right now
var stuff_spawned = 0

#Reference to levelManager
@onready var level_manager: Node3D = $"3DEnviorment"

#Add new bullets here
@onready var bullet_basic = preload("res://scenes/bullets/enemy_bullet_basic.tscn")

#Add new enemies here
@onready var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")

#Reference to UI
@onready var ui: Control = $"Debug-UI"
var win_text: Label = null;
var items_text: Label = null;

#Reference to player
@onready var player: CharacterBody2D = $"Player"

func _ready() -> void:
	player.items.clear()
	for l in ui.get_children():
		if l.name == "WinText":
			win_text = l;
			win_text.text = ""
		if l.name == "Items":
			items_text = l
			items_text.text = "Items: none"
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
		
func pick_items():
	#Generate 3 random items to pick from
	win_text.text = "SELECT ITEM\n>SPEED\nFRAMES"
	var item_selected = false
	var selection = 0
	while not item_selected:
		if Input.is_action_just_pressed("ui_up"):
			selection -= 1
			if selection < 0:
				selection = 1
			update_item_visuals(selection)
		if Input.is_action_just_pressed("ui_down"):
			selection += 1
			if selection > 1:
				selection = 0
			update_item_visuals(selection)
		if Input.is_action_just_pressed("ui_shoot"):
			if selection == 0:
				if player.items.get("SpeedBoost") == null:
					player.items["SpeedBoost"] = 0
				player.items["SpeedBoost"] += 1
			elif selection == 1:
				if player.items.get("BlinkExtend") == null:
					player.items["BlinkExtend"] = 0
				player.items["BlinkExtend"] += 1
			item_selected = true
		await Engine.get_main_loop().process_frame
	win_text.text = ""
	items_text.text = "Items:\n"
	for item in player.items.keys():
		items_text.text += item + ": " + str(player.items[item]) + "\n"
	
func update_item_visuals(a: int):
	if a == 0:
		win_text.text = "SELECT ITEM\n>SPEED\nFRAMES"
	elif a == 1:
		win_text.text = "SELECT ITEM\nSPEED\n>FRAMES"
#STAGES SECTION
func stage_1():
	await pick_items()
	
	await enemy_pattern_line_horiz_kamikaze(0)
	await wait_until_clear()
	
	await bullet_pattern_back_and_foth(3)
	await get_tree().create_timer(2.0).timeout
	
	await bullet_pattern_fan(1)
	await wait_until_clear()
	
	await pick_items()
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
	
	await pick_items()
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
