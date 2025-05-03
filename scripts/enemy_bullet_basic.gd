extends Area2D

var dir: Vector2 = Vector2(0.0,0.0)
@export var speed = 1

func _ready():
	add_to_group("bullet")
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(10).timeout
	if not entered:
		queue_free()
	
func  _physics_process(delta: float) -> void:
	position += dir * delta * speed

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
		
var entered = false
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered = true
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
