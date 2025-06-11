extends Control

@export var plr_health_bar: ProgressBar
@export var plr_ability_bar: ProgressBar

@export var crystal: Node
@export var sphere: Node
@export var steak: Node
@export var drug: Node

@export var level_label: Label
@export var enemies_label: Label
@export var bullets_label: Label

@export var game_over_obj: Label

var plr
var level = 0
var enemies = 0
var bullets = 0

var positions = [Vector2(1380,804), Vector2(1520,804), Vector2(1672,804), Vector2(1380,956)]

func _ready():
	plr = get_node("/root/Main/SubViewportContainer/Main_Viewport/Player")
	update_items()
	
func update_items():
	crystal.visible = false;
	sphere.visible = false;
	steak.visible = false;
	drug.visible = false;
	var i = 0;
	for key in plr.items.keys():
		match key:
			"ShootSpeed":
				crystal.position = positions[i]
				crystal.get_child(0).text = str(plr.items[key])
				crystal.visible = true;
			"AbilitySpeed":
				sphere.position = positions[i]
				sphere.get_child(0).text = str(plr.items[key])
				sphere.visible = true;
			"HpBoost":
				steak.position = positions[i]
				steak.get_child(0).text = str(plr.items[key])
				steak.visible = true;
			"DamageBoost":
				drug.position = positions[i]
				drug.get_child(0).text = str(plr.items[key])
				drug.visible = true;
		i += 1
	
func _process(_delta):
	var mhp;
	if plr.items.get("HpBoost") != null:
		mhp = plr.max_hp + (1 * plr.items["HpBoost"])
	else:
		mhp = plr.max_hp
	plr_health_bar.value = float(plr.hp)/float(mhp)
	plr_health_bar.material.set_shader_parameter("lives", plr.hp);
	plr_ability_bar.value = float(plr.ability_charge)/100.0
	level_label.text = "Current Stage: " + str(level + 1)
	enemies_label.text = "Enemies Defeated: " + str(enemies)
	bullets_label.text = "Bullets Shot: " + str(bullets)
func game_over():
	game_over_obj.visible = true
func not_game_over():
	game_over_obj.visible = false
