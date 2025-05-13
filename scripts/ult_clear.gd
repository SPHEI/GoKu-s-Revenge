extends Node2D


@onready var e = preload("res://scenes/effects/explosion_small.tscn")
func _ready() -> void:
	spawn(Vector2(150,300))
	spawn(Vector2(150,900))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(400,600))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(550,300))
	spawn(Vector2(550,900))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(800,600))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(950,300))
	spawn(Vector2(950,900))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(1200,600))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(1350,300))
	spawn(Vector2(1350,900))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(1600,600))
	await get_tree().create_timer(0.01).timeout
	spawn(Vector2(1750,300))
	spawn(Vector2(1750,900))
func spawn(pos):
	var a = e.instantiate()
	a.scale = Vector2(20,20)
	a.position = pos
	add_child(a)
