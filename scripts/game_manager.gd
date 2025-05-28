extends Node2D

#Viewport under which enemies are spawned
@onready var viewport = $"SubViewportContainer/Main_Viewport"
#Reference to levelManager
@onready var level_manager: Node3D = $"SubViewportContainer/Main_Viewport/3DEnviorment"

#Add new bullets here
@onready var bullet_basic = preload("res://scenes/bullets/enemy_bullet_basic.tscn")

@onready var point_spawner = preload("res://scenes/point_spawner.tscn")
#Add new enemies here
@onready var kamikaze = preload("res://scenes/enemies/kamikaze.tscn")
@onready var wah = preload("res://scenes/enemies/basic_enemy.tscn")
@onready var wah_tri = preload("res://scenes/enemies/basic_enemy_tri.tscn")
@onready var wah_side = preload("res://scenes/enemies/basic_enemy_side.tscn")
@onready var wah_side_tri = preload("res://scenes/enemies/basic_enemy_side_tri.tscn")
@onready var laser = preload("res://scenes/enemies/laser.tscn")
@onready var spinner_bullets = preload("res://scenes/enemies/spinner_bullets.tscn")
@onready var spinner_laser = preload("res://scenes/enemies/spinner_laser.tscn")
#Add new bosses here
@onready var test_boss = preload("res://scenes/bosses/test_boss.tscn")
@onready var aunn_boss = preload("res://scenes/bosses/aunn.tscn")
@onready var narumi_boss = preload("res://scenes/bosses/narumi.tscn")


@onready var transition = $"SubViewportContainer/Main_Viewport/Transition"
#Reference to UI
@onready var ui: Control = $"Debug-UI"
var win_text: Label = null;
var items_description: Label = null;
var enemies: Label = null;
var bullets: Label = null;
var boss_health_bar: ProgressBar = null;
var item_bg_panel: Panel = null;

var items = [
	#[Code name, display name, description]
	["ShootSpeed", "Focus Crystal", "Increases shooting speed by 50%."],
	["AbilitySpeed", "Soul Sphere", "Increases the amount of ability charge you get by +1%."],
	["HpBoost", "Well-Done Steak", "Increases maximum health by 1."],
	["DamageBoost", "Demondrug", "Increases damage dealt by 1."]
]

#Reference to player
@onready var player: CharacterBody2D = $"SubViewportContainer/Main_Viewport/Player"

func _ready() -> void:
	player.items.clear()
	for l in ui.get_children():
		if l.name == "WinText":
			win_text = l;
			win_text.text = ""
		if l.name == "ItemDesc":
			items_description = l
			items_description.text = ""
		if l.name == "Items2":
			enemies = l
		if l.name == "Items3":
			bullets = l
		if l.name == "Boss Health Bar":
			boss_health_bar = l
			l.visible = false
		if l.name == "Bg-Panel":
			item_bg_panel = l
	run_stage(stages[level_manager.current_level_id])
func _process(_delta: float) -> void:
	enemies.text = "Enemies: " + str(get_tree().get_node_count_in_group("enemies") + get_tree().get_node_count_in_group("bosses"))
	bullets.text = "Bullets: " + str(get_tree().get_node_count_in_group("bullets") + get_tree().get_node_count_in_group("bullet"))
	if not level_manager.updating:
		if Input.is_action_just_pressed("debug_nextScene"):
			cancel_stage = true
			boss_health_bar.visible = false
			while cancel_stage:
				await get_tree().create_timer(0.2).timeout
			transition.state = 0
			await get_tree().create_timer(0.1).timeout
			transition.state = 1
			await get_tree().create_timer(0.5).timeout
			await level_manager.next_level()
			transition.state = 2
			await get_tree().create_timer(0.5).timeout
			run_stage(stages[level_manager.current_level_id])
		if Input.is_action_just_pressed("debug_previousScene"):
			cancel_stage = true
			boss_health_bar.visible = false
			while cancel_stage:
				await get_tree().create_timer(0.2).timeout
			transition.state = 0
			await get_tree().create_timer(0.1).timeout
			transition.state = 1
			await get_tree().create_timer(0.5).timeout
			await level_manager.previous_level()
			transition.state = 2
			await get_tree().create_timer(0.5).timeout
			run_stage(stages[level_manager.current_level_id])
	
func spawn_enemy(type: Resource, pos: Vector2):
	var b = type.instantiate()
	b.position = pos
	var unique_material = preload("res://scenes/enemies/enemy_flash.tres").duplicate()
	b.get_node("AnimatedSprite2D").material = unique_material
	viewport.add_child(b)

func spawn_boss(type: Resource, pos: Vector2):
	var b = type.instantiate()
	b.position = pos
	b.health_bar = boss_health_bar
	var unique_material = preload("res://scenes/enemies/enemy_flash.tres").duplicate()
	b.get_node("AnimatedSprite2D").material = unique_material
	boss_health_bar.visible = true
	viewport.add_child(b)
	
func point_spawn_enemy(type: Resource, pos: Vector2):
	var b = point_spawner.instantiate()
	b.to_spawn = type
	b.position = pos
	viewport.add_child(b)
	
func point_spawn_boss(type: Resource, pos: Vector2):
	var b = point_spawner.instantiate()
	b.to_spawn = type
	b.boss = true
	b.health_bar = boss_health_bar
	b.position = pos
	viewport.add_child(b)
	
func spawn_bullet(type: Resource, pos: Vector2, dir: Vector2):
	var b = type.instantiate()
	b.position = pos
	b.dir = dir
	viewport.add_child(b)
func wait_until_clear():
	while get_tree().get_node_count_in_group("point spawners") > 0 or get_tree().get_node_count_in_group("enemies") > 0 or get_tree().get_node_count_in_group("bullet") > 0:
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return
func wait_until_boss_dead():
	while get_tree().get_node_count_in_group("point spawners") > 0 or get_tree().get_node_count_in_group("bosses") > 0:
		await get_tree().create_timer(0.2).timeout
		if cancel_stage:
			return
	boss_health_bar.visible = false
	
var current_options = [-1,-1,-1]
func pick_items():
	player.enabled = false
	item_bg_panel.go = true
	await get_tree().create_timer(0.5).timeout
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
	player.reset_hp()
	ui.update_items()
	item_bg_panel.go = false
	await get_tree().create_timer(0.5).timeout
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
		"wait-1.0",
		"bullet_pattern_down",
		"wait-6.0",
		"enemy_pattern_middle_kamikaze",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"wait_until_clear",
		"enemy_pattern_two_basic",
		"wait_until_clear",
		"enemy_pattern_line_horiz_basic",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"bullet_pattern_down",
		"enemy_pattern_line_horiz_kamikaze",
		"wait_until_clear",
		"enemy_pattern_trio_basic_tri",
		"wait_until_clear",
		"wait-1.0",
		"boss_test_spawn",
		"wait_until_boss_dead",
		"pick_items",
	],
	[	#Stage 2
		"bullet_pattern_fan",
		"wait-2.0",
		"bullet_pattern_fan_left",
		"wait-10.0",
		"enemy_pattern_line_horiz_basic",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_left",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_right",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-2.0",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-2.0",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-2.0",
		"enemy_pattern_line_vert_basic_side_both",
		"wait-2.0",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-4.0",
		"bullet_pattern_down",
		"enemy_pattern_around_spinner_bullets",
		"wait_until_clear",
		"enemy_pattern_line_horiz_basic_tri",
		"wait_until_clear",
		"enemy_pattern_line_horiz_basic_tri",
		"enemy_pattern_line_vert_basic_side_both",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_tri_both",
		"wait_until_clear",
		"wait-1.0",
		"boss_aunn_spawn",
		"wait_until_boss_dead",
		"pick_items",
	],
	[	#Stage 3
		"enemy_pattern_middle_laser",
		"wait_until_clear",
		"enemy_pattern_line_horiz_laser",
		"wait_until_clear",
		"enemy_center_spinner_laser",
		"wait_until_clear",
		"enemy_pattern_line_horiz_laser",
		"enemy_center_spinner_laser",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"enemy_pattern_line_vert_basic_side_both",
		"wait-2.0",
		"enemy_pattern_line_horiz_basic_tri",
		"wait_until_clear",
		"enemy_center_spinner_laser",
		"enemy_pattern_line_vert_basic_side_tri_both",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"enemy_pattern_line_horiz_laser",
		"enemy_pattern_around_spinner_bullets",
		"wait_until_clear",
		"bullet_pattern_fan",
		"wait-2.0",
		"bullet_pattern_fan_left",
		"wait-10.0",
		"wait_until_clear",
		"bullet_pattern_side",
		"wait_until_clear",
		"enemy_pattern_around_spinner_bullets",
		"enemy_center_spinner_laser",
		"wait-1.0",
		"enemy_center_spinner_laser",
		"wait_until_clear",
		"wait-1.0",
		"boss_narumi_spawn",
		"wait_until_boss_dead",
		"pick_items",
	],
	[	#Stage 4
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"enemy_pattern_around_spinner_bullets",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait_until_clear",
		"enemy_center_spinner_laser",
		"enemy_pattern_line_vert_basic_side_both",
		"bullet_pattern_back_and_foth",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_tri_left",
		"enemy_pattern_around_spinner_bullets",
		"enemy_pattern_line_horiz_laser",
		"bullet_pattern_side",
		"wait_until_clear",
		"enemy_center_spinner_laser",
		"wait-1.0",
		"enemy_center_spinner_laser",
		"enemy_pattern_line_horiz_basic_tri",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"wait_until_clear",
		"enemy_around_basic_and_tri",
		"wait_until_clear",
		"enemy_around_kamikaze",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_around_kamikaze",
		"wait-0.4",
		"enemy_pattern_line_horiz_kamikaze",
		"wait-0.4",
		"enemy_around_kamikaze",
		"wait-0.4",
		"enemy_pattern_around_spinner_bullets",
		"wait_until_clear",
		"wait-3.0",
		"boss_aunn_spawn",
		"wait-1.0",
		"boss_aunn_spawn",
		"wait-3.0",
		"boss_test_spawn",
		"wait-3.0",
		"boss_test_spawn",
		"wait_until_boss_dead",
		"boss_narumi_spawn",
		"wait_until_boss_dead",
		"win_game"
	],
	[	#Test stage
		"pick_items",
		"boss_test_spawn",
		"wait_until_boss_dead",
		"enemy_center_spinner_laser",
		"wait-1.0",
		"enemy_center_spinner_laser",
		"wait_until_clear",
		"bullet_pattern_side",
		"wait_until_clear",
		"enemy_center_spinner_laser",
		"wait_until_clear",
		"enemy_pattern_line_horiz_laser",
		"wait_until_clear",
		"bullet_pattern_fan",
		"wait_until_clear",
		"enemy_pattern_line_horiz_kamikaze",
		"wait_until_clear",
		"enemy_pattern_line_horiz_basic",
		"wait_until_clear",
		"enemy_pattern_line_horiz_basic_tri",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_left",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_right",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_both",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_tri_left",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_tri_right",
		"wait_until_clear",
		"enemy_pattern_line_vert_basic_side_tri_both",
		"wait_until_clear",
		"enemy_pattern_around_spinner_bullets",
		"wait_until_clear",
		"boss_test_spawn",
		"bullet_pattern_back_and_foth",
		"wait_until_clear",
		"wait_until_boss_dead",
		"pick_items"
	],
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
	transition.state = 0
	await get_tree().create_timer(0.1).timeout
	transition.state = 1
	await get_tree().create_timer(0.5).timeout
	await level_manager.next_level()
	transition.state = 2
	await get_tree().create_timer(0.5).timeout
	run_stage(stages[level_manager.current_level_id])
	
func win_game():
	win_text.text = "You won!"
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://scenes/Credits.tscn")
	
	
#640 is the middle of the screen
#BULLET PATTERN SECTION
func bullet_pattern_line_horiz_basic(offset: float, dir: Vector2):
	for i in range(15):
		spawn_bullet(bullet_basic, Vector2(100.0 * i + offset,-4.0), dir)
func bullet_pattern_line_vert_basic_left(offset: float, dir: Vector2):
	for i in range(15):
		spawn_bullet(bullet_basic, Vector2(-4,100 * i + offset), dir)
func bullet_pattern_line_vert_basic_right(offset: float, dir: Vector2):
	for i in range(15):
		spawn_bullet(bullet_basic, Vector2(1284,100 * i + offset), dir)
func bullet_pattern_side():
	var a = false
	for i in range(10):
		if a:
			bullet_pattern_line_vert_basic_left(0.0, Vector2(200.0,0.0))
			a = false
		else:
			bullet_pattern_line_vert_basic_right(50.0, Vector2(-200.0,0.0))
			a = true
		await get_tree().create_timer(0.5).timeout
		if cancel_stage:
			return
func bullet_pattern_down():
	var a = false
	for i in range(5):
		if a:
			bullet_pattern_line_horiz_basic(50.0, Vector2(0.0,100.0))
			a = false
		else:
			bullet_pattern_line_horiz_basic(0.0, Vector2(0.0,100.0))
			a = true
		await get_tree().create_timer(2.0).timeout
		if cancel_stage:
			return
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
	for i in range(15):
		bullet_pattern_line_horiz_basic(0.0, Vector2(2.0 * i,50.0))
		await get_tree().create_timer(0.4).timeout
		if cancel_stage:
			return
func bullet_pattern_fan_left():
	for i in range(15):
		bullet_pattern_line_horiz_basic(0, Vector2(-2.0 * i,50.0))
		await get_tree().create_timer(0.4).timeout
		if cancel_stage:
			return

#ENEMY PATTERN SECTION
func enemy_pattern_middle_kamikaze():
	spawn_enemy(kamikaze, Vector2(640,-4.0))
func enemy_pattern_line_horiz_kamikaze():
	for i in range(10):
		spawn_enemy(kamikaze, Vector2(100.0 + 130.0 * i,-4.0))
		
func enemy_pattern_two_basic():
	spawn_enemy(wah, Vector2(540,-4.0))	
	spawn_enemy(wah, Vector2(740,-4.0))	
func enemy_pattern_line_horiz_basic():
	for i in range(5):
		spawn_enemy(wah, Vector2(100.0 + 260.0 * i,-4.0))	
func enemy_pattern_trio_basic_tri():
	spawn_enemy(wah_tri, Vector2(640,-4.0))
	spawn_enemy(wah_tri, Vector2(440,-4.0))	
	spawn_enemy(wah_tri, Vector2(840,-4.0))	
func enemy_pattern_line_horiz_basic_tri():
	for i in range(5):
		spawn_enemy(wah_tri, Vector2(100.0 + 260.0 * i,-4.0))	
		
func enemy_pattern_middle_laser():
	spawn_enemy(laser, Vector2(640,-100.0))	
	
func enemy_pattern_line_horiz_laser():
	for i in range(5):
		if i == 2:
			continue
		spawn_enemy(laser, Vector2(100.0 + 260.0 * i,-100.0))	
		
func enemy_pattern_line_vert_basic_side_left():
	for i in range(5):
		spawn_enemy(wah_side, Vector2(-100.0, 100.0 * i + 100.0))
		
func enemy_pattern_line_vert_basic_side_right():
	for i in range(5):
		spawn_enemy(wah_side, Vector2(1350.0, 100.0 * i + 100.0))
		
func enemy_pattern_line_vert_basic_side_both():
	enemy_pattern_line_vert_basic_side_left()
	enemy_pattern_line_vert_basic_side_right()
	
func enemy_pattern_line_vert_basic_side_tri_left():
	for i in range(5):
		spawn_enemy(wah_side_tri, Vector2(-100.0, 100.0 * i + 100.0))
		
func enemy_pattern_line_vert_basic_side_tri_right():
	for i in range(5):
		spawn_enemy(wah_side_tri, Vector2(1350.0, 100.0 * i + 100.0))
		
func enemy_pattern_line_vert_basic_side_tri_both():
	enemy_pattern_line_vert_basic_side_tri_left()
	enemy_pattern_line_vert_basic_side_tri_right()
	
func enemy_pattern_around_spinner_bullets():
	for i in range(5):
		var angle = i * TAU / 5
		point_spawn_enemy(spinner_bullets,Vector2(640,500) + Vector2(sin(angle) * 1.25, cos(angle)*-1) * 400.0)
		await get_tree().create_timer(0.05).timeout
		
func enemy_center_spinner_laser():
	point_spawn_enemy(spinner_laser,Vector2(640,500))
	
func enemy_around_basic_and_tri():
	for i in range(10):
		var angle = i * TAU / 10
		if i % 2 == 0:
			point_spawn_enemy(wah,Vector2(640,500) + Vector2(sin(angle) * 1.25, cos(angle)*-1) * 400.0)
		else:
			point_spawn_enemy(wah_tri,Vector2(640,500) + Vector2(sin(angle) * 1.25, cos(angle)*-1) * 400.0)
		await get_tree().create_timer(0.05).timeout
func enemy_around_kamikaze():
	for i in range(10):
		var angle = i * TAU / 10
		point_spawn_enemy(kamikaze,Vector2(640,500) + Vector2(sin(angle) * 1.25, cos(angle)*-1) * 400.0)
		await get_tree().create_timer(0.05).timeout
#BOSS SECTION
func boss_test_spawn():
	point_spawn_boss(test_boss, Vector2(640.0,250.0))
	
func boss_aunn_spawn():
	point_spawn_boss(aunn_boss, Vector2(640.0,250.0))
	
func boss_narumi_spawn():
	point_spawn_boss(narumi_boss, Vector2(640.0,250.0))
