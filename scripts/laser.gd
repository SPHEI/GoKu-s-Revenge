extends Area2D


var can_hit = false
var plr: Node2D
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var plr_in_range = false
func _process(delta):
	if can_hit and plr_in_range and scale.x == 2:
		plr.hit()
	if can_hit and scale.x < 2:
		scale.x += delta * 4
		if scale.x > 2:
			scale.x = 2
	if not can_hit and scale.x > 0:
		scale.x -= delta * 4
		if scale.x < 0:
			scale.x = 0
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		plr = body
		plr_in_range = true;
func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		plr_in_range = false;
