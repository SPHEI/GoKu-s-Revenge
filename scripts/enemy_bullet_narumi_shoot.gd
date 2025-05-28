
extends Area2D

@export var target_position: Array
@export var move_speed := 100.0


var epsilon := 1.0
var current_target := 0

func _ready():
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(10).timeout
	if not entered:
		queue_free()
	
#func  _physics_process(delta: float) -> void:
#	position += dir * delta * speed


func _physics_process(delta):
	if current_target < target_position.size() and target_position[current_target] != Vector2.ZERO:
		global_position = global_position.move_toward(target_position[current_target], move_speed * delta)
	
		if global_position.distance_to(target_position[current_target]) <= epsilon:
			current_target+=1
	pass



func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
		
var entered = false
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered = true
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
