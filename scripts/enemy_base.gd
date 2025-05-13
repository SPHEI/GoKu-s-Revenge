extends Area2D

class_name Enemy

@onready var explosion = preload("res://scenes/effects/explosion_small.tscn")

@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@export var hp = 1
#Call this from player bullet script
func get_hit():
	hp -= 1
	if hp <= 0:
		var e = explosion.instantiate()
		e.position = position
		get_tree().root.add_child(e)
		get_tree().get_nodes_in_group("player")[0].inc_ability()
		queue_free()
	elif not flashing:
		flash()

var flashing = false
func flash():
	var shader_material = sprite.material as ShaderMaterial
	if shader_material:
		flashing = true
		var i = 1.0
		shader_material.set_shader_parameter("level", i)
		await get_tree().create_timer(0.1).timeout
		for j in range(10):
			shader_material.set_shader_parameter("level", i)
			i *= 0.8
			await get_tree().create_timer(0.01).timeout
		shader_material.set_shader_parameter("level", 0)
		flashing = false
