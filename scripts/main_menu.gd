extends Control

@export var options: Label
@export var subtitle: Label
@export var cred: Label
var selection := 0  # 0 = Play, 1 = Don't, 2 = Credits
var credits := false

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		selection = (selection + 1) % 3
		update_text()
	elif Input.is_action_just_pressed("ui_up") && !credits:
		selection = (selection + 2) % 3  # equivalent to (selection - 1 + 3) % 3
		update_text()

	if Input.is_action_just_pressed("ui_shoot") && !credits:
		match selection:
			0:
				get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
			1:
				get_tree().quit()
			2:
				#get_tree().change_scene_to_file("res://scenes/Credits.tscn")
				credits = true
				options.visible = false
				cred.visible = true
				subtitle.text = "Thanks for playing!"
				
	if Input.is_action_just_pressed("ui_cancel"):
		credits = false
		cred.visible = false
		options.visible = true
		subtitle.text = "The Epic Copyright-Infringement Journey!"

func update_text():
	match selection:
		0:
			options.text = ">Play\nDon't\nCredits"
		1:
			options.text = "Play\n>Don't\nCredits"
		2:
			options.text = "Play\nDon't\n>Credits"
