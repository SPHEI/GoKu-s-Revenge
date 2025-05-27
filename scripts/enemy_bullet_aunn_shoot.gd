extends Area2D

@export var move_speed = 50
@export var target_position := Vector2.ZERO

var plr: Node
var epsilon = 1.0
var done := false
var direction := Vector2(1.0, 1.0)

func _ready():
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(10).timeout
	if not entered:
		queue_free()
	
#func  _physics_process(delta: float) -> void:
#	position += dir * delta * speed


func _process(delta):
	if target_position != Vector2.ZERO && !done:
		global_position = global_position.move_toward(target_position, move_speed * delta)
	
		if global_position.distance_to(target_position) <= epsilon:
			direction = position.direction_to(plr.global_position)
			done = true
			move_speed = 1000
	else:
		global_position += direction * delta * move_speed



func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
		
var entered = false
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered = true
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
