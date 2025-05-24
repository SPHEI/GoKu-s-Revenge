extends Control

var quit = false
@export var options: Label
func _process(_delta):
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		quit = !quit
		update_text()
	if Input.is_action_just_pressed("ui_shoot"):
		if quit:
			get_tree().quit()
		else:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
func update_text():
	if quit:
		options.text = "Play\n>Don't"
	else:
		options.text = ">Play\nDon't"
