extends Area2D

@export var delay = 0.4
@export var speed = 20

var can_attack = true

func _ready():
	add_to_group("enemies")
	pass

func _process(delta: float) -> void:
	position.y += speed * delta
	if can_attack == true:
		spawn()
		get_tree().create_timer(delay).timeout.connect(func(): can_attack = true)
		can_attack = false

@onready var bullet_basic = preload("res://scenes/bullets/tracking_enemy_bullet.tscn")

func spawn():
	var bullet_1 = bullet_basic.instantiate()
	add_child(bullet_1)
	
	pass

func get_hit():
	get_parent().stuff_spawned -= 1
	queue_free()
