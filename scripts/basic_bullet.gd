extends Area2D

@export var speed = 1500
@export var velocity : Vector2

var damage = 1

@onready var hit_effect = preload("res://scenes/effects/bullet_hit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player_bullets")
	area_entered.connect(_on_area_entered)
	await get_tree().create_timer(1).timeout
	if not entered:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position += transform.x * vector.x * delta
	position -= transform.y * speed * delta

func _on_area_entered(area: Node2D):
	if area.is_in_group("enemies") or area.is_in_group("bosses"):
		area.get_hit(damage)
		var a = hit_effect.instantiate()
		a.position = position
		get_node("/root/Main/SubViewportContainer/Main_Viewport/PlayerBulletsScene").add_child(a)
		queue_free()
	
var entered = false
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
