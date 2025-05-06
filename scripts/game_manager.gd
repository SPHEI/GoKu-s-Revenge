extends Node2D

#Reference to levelManager
@onready var level_manager: Node3D = $"3DEnviorment"

#Add new bullets here
@onready var bullet_basic = preload("res://scenes/bullets/enemy_bullet_basic.tscn")

#Add new enemies here
@onready var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")
@onready var wah = preload("res://scenes/enemies/basic_enemy.tscn")

#Add new bosses here
@onready var test_boss = preload("res://scenes/bosses/test_boss.tscn")

#Reference to UI
@onready var ui: Control = $"Debug-UI"
var win_text: Label = null;
var items_text: Label = null;
var items_description: Label = null;
var hp: Label = null;
var enemies: Label = null;
var bullets: Label = null;
var boss_health_bar: ProgressBar = null;

var items = [
	#[Code name, display name, description]
	["ShootSpeed", "Focus Crystal", "Increases shooting speed by 50%."],
	["AbilitySpeed", "Soul Sphere", "Increases the amount of ability charge you get by +1%. (not implemented yet)"],
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
		if l.name == "Items2":
			enemies = l
		if l.name == "Items3":
			bullets = l
		if l.name == "Boss Health Bar":
			boss_health_bar = l
			l.visible = false
		#print(l.name)
	run_stage(stages[level_manager.current_level_id])
func _process(_delta: float) -> void:
	hp.text = "Hp: " + str(player.hp)
	enemies.text = "Enemies: " + str(get_tree().get_node_count_in_group("enemies") + get_tree().get_node_count_in_group("bosses"))
	bullets.text = "Bullets: " + str(get_tree().get_node_count_in_group("bullets") + get_tree().get_node_count_in_group("bullet"))
	if not level_manager.updating:
		if Input.is_action_just_pressed("debug_nextScene"):
			cancel_stage = true
			while cancel_stage:
				await get_tree().create_timer(0.2).timeout
			await level_manager.next_level()
			run_stage(stages[level_manager.current_level_id])
		if Input.is_action_just_pressed("debug_previousScene"):
			cancel_stage = true
			while cancel_stage:
				await get_tree().create_timer(0.2).timeout
			await level_manager.previous_level()
			run_stage(stages[level_manager.current_level_id])
	
func spawn_enemy(type: Resource, pos: Vector2):
	var b = type.instantiate()
	b.position = pos
	add_child(b)

func spawn_boss(type: Resource, pos: Vector2):
	var b = type.instantiate()
	b.position = pos
	b.health_bar = boss_health_bar
	boss_health_bar.visible = true
	add_child(b)
	
func spawn_bullet(type: Resource, pos: Vector2, dir: Vector2):
	var b = type.instantiate()
	b.position = pos
	b.dir = dir
	add_child(b)
	
func wait_until_clear():
	while get_tree().get_node_count_in_group("enemies") > 0 or get_tree().get_node_count_in_group("bullet") > 0:
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return
func wait_until_boss_dead():
	while get_tree().get_node_count_in_group("bosses") > 0:
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return
	boss_health_bar.visible = false
	
var current_options = [-1,-1,-1]
func pick_items():
	player.enabled = false
	#Generate 3 random options to pick from
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	var options_left = []
	options_left.resize(items.size())
	for i in range(items.size()):
		options_left[i] = i
		#print(i)
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
		if cancel_stage:
			item_selected = true
		
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
@export var stages = [
	[	#Stage 1
		"pick_items",
		"boss_test_spawn",
		"wait_until_boss_dead",
		"enemy_pattern_line_horiz_basic",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"wait_until_clear",
		"bullet_pattern_back_and_foth",
		"bullet_pattern_back_and_foth",
		"bullet_pattern_back_and_foth",
		"wait-2.0",
		"bullet_pattern_fan",
		"wait_until_clear",
		"boss_test_spawn",
		"wait_until_boss_dead",
		"pick_items"
	],
	[	#Stage 2
		"enemy_pattern_line_horiz_kamikaze",
		"wait-2.0",
		"enemy_pattern_line_horiz_kamikaze",
		"wait_until_clear",
		"bullet_pattern_fan",
		"wait-1.0",
		"bullet_pattern_fan",
		"wait_until_clear",
		"pick_items",
		"win_game"
	],
	[	#Stage 3
		"wait-5.0",
	]
]

var cancel_stage = false
func run_stage(list):
	player.reset_hp()
	for action in list:
		#print(action)
		if action == "win_game":
			call(action)
			return
		elif action.left(5) == "wait-":
			#print(action.get_slice("-",1))
			await get_tree().create_timer(action.get_slice("-",1).to_float()).timeout
		else:
			if has_method(action):
				await call(action)
		if cancel_stage:
			cancel_stage = false
			return
	await level_manager.next_level()
	run_stage(stages[level_manager.current_level_id])
	
func win_game():
	win_text.text = "You won!"
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
#BULLET PATTERN SECTION
func bullet_pattern_line_horiz_basic(offset: float, dir: Vector2):
	for i in range(20):
		spawn_bullet(bullet_basic, Vector2(100.0 * i + offset,-4.0), dir)
func bullet_pattern_back_and_foth():
	for i in range(10):
		bullet_pattern_line_horiz_basic(20.0 * i, Vector2(0.0,100.0))
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return
	for i in range(10):
		bullet_pattern_line_horiz_basic(200.0 - 20.0 * i, Vector2(0.0,100.0))
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return
func bullet_pattern_fan():
	for i in range(30):
		bullet_pattern_line_horiz_basic(0.0, Vector2(1.0 * i,50.0))
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return

#ENEMY PATTERN SECTION
func enemy_pattern_line_horiz_kamikaze():
	for i in range(10):
		spawn_enemy(kamikaze, Vector2(200.0 * i,-4.0))
		
func enemy_pattern_line_horiz_basic():
	for i in range(10):
		spawn_enemy(wah, Vector2(200.0 * i,-4.0))	
		
#BOSS SECTION
func boss_test_spawn():
	spawn_boss(test_boss, Vector2(1000.0,250.0))
