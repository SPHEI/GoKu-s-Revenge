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
var items_description: Label = null;
var hp: Label = null;

'''
ITEMS:
SpeedBoost: Boosts Movement speed by 10% (+10 per stack)
BlinkExtend: Extends after-hit invincibility by 50% (+50 per stack)
ShootSpeed: Boosts shooting speed by 50% (+50% per stack)
AbilitySpeed: Boosts the charge rate of ability by +1% (+1 per stack) every time charge is gained.
HpBoost: +1 maxHp per stack
'''
var items = [
	#[Code name, display name, description]
	["SpeedBoost", "Energy Drink", "Increases movement speed by 10%."],
	["BlinkExtend", "Clear Mantle", "Increases invulnerability time after you get hit by 50%."],
	["ShootSpeed", "Focus Crystal", "Increases shooting speed by 50%."],
	["AbilitySpeed", "Soul Sphere", "Increases the amount of ability charge you get by +1%."],
	["HpBoost", "Well-Done Steak", "Increases maximum health by 1."]
]

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
		if l.name == "ItemDesc":
			items_description = l
			items_description.text = ""
		if l.name == "Hp":
			hp = l
	stage_1()
func _process(_delta: float) -> void:
	hp.text = "Hp: " + str(player.hp)
	
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

var current_options = [-1,-1,-1]
func pick_items():
	player.enabled = false
	#Generate 3 random options to pick from
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	var options_left = [0,1,2,3,4]
	for i in range(3):
		rng.randomize()
		var x = rng.randi_range(0, options_left.size()-1)
		current_options[i] = options_left[x]
		options_left.remove_at(x)
	
	update_item_visuals(0)
	var item_selected = false
	var selection = 0
	while not item_selected:
		if Input.is_action_just_pressed("ui_up"):
			selection -= 1
			if selection < 0:
				selection = 2
			update_item_visuals(selection)
		if Input.is_action_just_pressed("ui_down"):
			selection += 1
			if selection > 2:
				selection = 0
			update_item_visuals(selection)
			
		if Input.is_action_just_pressed("ui_shoot"):
			if player.items.get(items[current_options[selection]][0]) == null:
				player.items[items[current_options[selection]][0]] = 0
			player.items[items[current_options[selection]][0]] += 1
			item_selected = true
		await Engine.get_main_loop().process_frame
		
	win_text.text = ""
	items_description.text = ""
	items_text.text = "Items:\n"
	for item in player.items.keys():
		items_text.text += item + ": " + str(player.items[item]) + "\n"
	player.reset_hp()
	player.enabled = true
	
func update_item_visuals(a: int):
	win_text.text = "SELECT ITEM\n"
	for i in range(3):
		if a == i:
			win_text.text += ">"
		win_text.text += items[current_options[i]][1] + "\n"
	items_description.text = items[current_options[a]][2]
	
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
