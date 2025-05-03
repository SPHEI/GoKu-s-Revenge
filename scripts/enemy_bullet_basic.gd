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

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
