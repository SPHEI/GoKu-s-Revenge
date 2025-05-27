extends Area2D

class_name Enemy

@onready var explosion = preload("res://scenes/effects/explosion_small.tscn")

@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@export var hp = 1
#Call this from player bullet script

var can_get_hit = true;
func get_hit(damage):
	if can_get_hit:
		hp -= damage
		if hp <= 0:
			can_get_hit = false;
			var e = explosion.instantiate()
			e.position = position
			get_node("/root/Main/SubViewportContainer/Main_Viewport").add_child(e)
			get_tree().get_nodes_in_group("player")[0].inc_ability()
			get_node("/root/Main/Debug-UI").enemies += 1
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
