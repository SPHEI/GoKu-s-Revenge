extends Marker2D

@export var delay = 0.9

var can_attack = true

func _process(delta: float) -> void:
	if can_attack == true:
		spawn()
		get_tree().create_timer(delay).timeout.connect(func(): can_attack = true)
		can_attack = false

@onready var bullet_basic = preload("res://scenes/bullets/tracking_enemy_bullet.tscn")
		
func spawn():
	var marker_root = get_node("/root/Main/EnemyBulletsScene")
	var bullet_1 = bullet_basic.instantiate()
	bullet_1.global_position = global_position
	marker_root.add_child(bullet_1)
	
	pass
