extends Area2D

var dir: Vector2 = Vector2(0.0,0.0)
@export var speed = 1

var screen_size # Size of the game window.

func _ready():
	add_to_group("bullet")
	body_entered.connect(_on_body_entered)
	screen_size = get_viewport_rect().size
	
func  _physics_process(delta: float) -> void:
	position += dir * delta * speed
	if position.x > screen_size.x + 5.0 or position.x < -5.0 or position.y > screen_size.y + 5.0 or position.y < -5.0:
		get_parent().stuff_spawned -= 1
		queue_free()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
