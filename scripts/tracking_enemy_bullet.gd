extends Area2D

var dir: Vector2 = Vector2(0.0,0.0)
var plr: Node

@export var speed = 100


var screen_size # Size of the game window.

func _ready():
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)
	plr = get_tree().get_nodes_in_group("player")[0]
	screen_size = get_viewport_rect().size
	dir = (plr.global_position - global_position).normalized()
	
	
func  _physics_process(delta: float) -> void:
	position += dir * delta * speed

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
