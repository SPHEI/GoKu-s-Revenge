extends Node2D

@onready var bullet_basic = preload("res://scenes/bullets/bullet.tscn")
var can_attack = true


func spawn(speed, damage):
	if can_attack:
		shoot(damage)
		can_attack = false
		get_tree().create_timer(0.25 * pow(0.5, speed)).timeout.connect(func(): can_attack = true)

func shoot(damage):
	var marker_root = get_node("/root/Main/PlayerBulletsScene")

	for marker in get_children():
		if marker is Marker2D:
			var bullet_1 = bullet_basic.instantiate()
			bullet_1.global_position = marker.global_position
			bullet_1.damage = damage
			marker_root.add_child(bullet_1)
	
