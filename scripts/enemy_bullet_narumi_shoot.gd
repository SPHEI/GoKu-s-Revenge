
extends Area2D

@export var target_position := Vector2.ZERO
@export var move_speed := 2.0
@export var arc_height := 10.0  # Controls the curve height

var _initial_distance: float
var _direction: Vector2
var epsilon := 1.0
var plr: Node

func _ready():
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)
	plr = get_tree().get_nodes_in_group("player")[0]
	await get_tree().create_timer(10).timeout
	if not entered:
		queue_free()
	
#func  _physics_process(delta: float) -> void:
#	position += dir * delta * speed


func _physics_process(delta):
	if target_position == Vector2.ZERO:
		return
	
	var new_pos = global_position.move_toward(target_position, move_speed * delta)
	var remaining_distance = global_position.distance_to(target_position)
	var progress = 1.0 - (remaining_distance / _initial_distance)
	var arc_offset = _direction.rotated(PI/2) * arc_height * sin(progress * PI)

	global_position = new_pos + (arc_offset * delta)


	#rotation = _direction.angle()
#	if global_position.distance_to(target_position) <= epsilon:
#		direction = position.direction_to(plr.global_position)
#		done = true
#		move_speed = 1000
#	else:
#		global_position += direction * delta * move_speed



func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.hit()
		
var entered = false
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered = true
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
