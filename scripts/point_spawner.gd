extends Node2D

@onready var sprite = $Sprite2D
@export var to_spawn: Resource

var boss = false
var health_bar: ProgressBar

func _ready():
	add_to_group("point spawners")
	while not sprite.done:
		await get_tree().create_timer(0.02).timeout
	await get_tree().create_timer(0.5).timeout
	var a = to_spawn.instantiate()
	a.position = position
	if boss:
		a.health_bar = health_bar
		health_bar.visible = true
	var unique_material = preload("res://scenes/enemies/enemy_flash.tres").duplicate()
	a.get_node("AnimatedSprite2D").material = unique_material
	get_node("/root/Main/SubViewportContainer/Main_Viewport/PlayerBulletsScene").add_child(a)
	a.flash()
	sprite.expand = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
