extends Area2D

@export var speed = 750
@export var velocity : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position += transform.x * vector.x * delta
	position -= transform.y * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
