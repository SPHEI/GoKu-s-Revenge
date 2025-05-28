extends Node2D

@onready var bullet_basic = preload("res://scenes/bullets/bullet.tscn")
var can_attack = true
var spawner: Array[Marker2D] = []
var root: Array[Marker2D] = []
var target: Array[Marker2D] = []
var direction := false
var move_speed := 200
var epsilon = 1.0

func _ready() -> void:
	var marker_root = get_node("/root/Main/SubViewportContainer/Main_Viewport/PlayerBulletsScene")

	for marker in get_children():
		if marker is Marker2D:
			if marker.name.begins_with("spawner-"):
				spawner.append(marker)
			if marker.name.begins_with("root-"):
				root.append(marker)
			if marker.name.begins_with("target-"):
				target.append(marker)
				
func spawn(speed, damage):
	if can_attack:
		shoot(damage)
		can_attack = false
		get_tree().create_timer(0.15 * pow(0.5, speed)).timeout.connect(func(): can_attack = true)

func _process(delta: float) -> void:
	if direction:
		for w in range(spawner.size()):
			if spawner[w].global_position.distance_to(target[w].global_position) >= epsilon:
				spawner[w].global_position = spawner[w].global_position.move_toward(target[w].global_position, move_speed * delta)
			else:
				return
	else:
		for w in range(spawner.size()):
			if spawner[w].global_position.distance_to(root[w].global_position) >= epsilon:
				spawner[w].global_position = spawner[w].global_position.move_toward(root[w].global_position, move_speed * delta)
			else:
				return

func shoot(damage):
	var marker_root = get_node("/root/Main/SubViewportContainer/Main_Viewport/PlayerBulletsScene")
	
	for w in range(spawner.size()):
		var bullet_1 = bullet_basic.instantiate()
		get_node("/root/Main/Debug-UI").bullets += 1
		bullet_1.global_position = spawner[w].global_position
		bullet_1.damage = damage
		marker_root.add_child(bullet_1)

	
