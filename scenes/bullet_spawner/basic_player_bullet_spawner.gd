extends Node2D

@onready var bullet_basic = preload("res://scenes/bullets/bullet.tscn")
var can_attack = true


func spawn():
	if can_attack:
		shoot()
		can_attack = false
		get_tree().create_timer(0.1).timeout.connect(func(): can_attack = true)

func shoot():
	var marker_root = get_node("/root/Main/PlayerBulletsScene")

	for marker in get_children():
		if marker is Marker2D:
			var bullet_1 = bullet_basic.instantiate()
			bullet_1.global_position = marker.global_position
			marker_root.add_child(bullet_1)
	
