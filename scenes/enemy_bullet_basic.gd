extends Area2D

var dir: Vector2 = Vector2(0.0,0.0)
var screen_size # Size of the game window.

func _ready():
	body_entered.connect(_on_body_entered)
	screen_size = get_viewport_rect().size
	
func _process(delta: float) -> void:
	position += dir * delta
	if position.x > screen_size.x + 5.0 or position.x < -5.0 or position.y > screen_size.y + 5.0 or position.y < -5.0:
		get_parent().stuffSpawned -= 1
		queue_free()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
