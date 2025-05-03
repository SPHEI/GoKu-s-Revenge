extends Node3D

var current_level_objects = [null,null,null]
var current_level_id = 0
#speed up to check if scrolling is aligned properly
@export var speed = 10.0
#Add new levels here
var scene_list = [
	#[Scene name, Scene length]
	["res://scenes/levels/plains.tscn", 200],
	["res://scenes/levels/ocean.tscn", 255],
	["res://scenes/levels/test_plane.tscn",200],
]

@export var ui: Control = null;
var label: Label = null;
var loading: Label = null;

func _ready():
	for l in ui.get_children():
		if l.name == "CurrentLevel":
			label = l;
		if l.name == "Loading":
			loading = l;
	#change number to change starting level
	update_level()
func _physics_process(delta: float):
	if current_level_objects[0] != null and current_level_objects[1] != null and current_level_objects[2] != null:
		for i in range(3):
			current_level_objects[i].position += Vector3(0,0,speed) * delta
		if current_level_objects[1].position.z > 0:
			for i in range(3):
				current_level_objects[i].position = Vector3(0,0,-scene_list[current_level_id][1] * i)

var updating = false
func update_level():
	for node in get_tree().get_nodes_in_group("bullets"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("bullet"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("enemies"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("bosses"):
		node.queue_free()
	loading.text = "Loading..."
	updating = true
	label.text = "Current Level: " + str(current_level_id)
	ResourceLoader.load_threaded_request(scene_list[current_level_id][0])
	for i in range(3):
		if current_level_objects[i] != null:
			remove_child(current_level_objects[i])
	while(ResourceLoader.load_threaded_get_status(scene_list[current_level_id][0]) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS):
			await get_tree().create_timer(0.2).timeout
	var l = ResourceLoader.load_threaded_get(scene_list[current_level_id][0])
	for i in range(3):
		current_level_objects[i] = l.instantiate()
		add_child(current_level_objects[i])
		current_level_objects[i].position = Vector3(0,0,-scene_list[current_level_id][1] * i)
		if i > 0:
			for child in current_level_objects[i].get_children():
				if child is DirectionalLight3D or child is WorldEnvironment:
					current_level_objects[i].remove_child(child)
	updating = false
	loading.text = ""

func next_level():
	current_level_id += 1
	if current_level_id >= scene_list.size():
		current_level_id = 0
	await update_level()

func previous_level():
	current_level_id -= 1
	if current_level_id < 0:
		current_level_id = scene_list.size() - 1
	await update_level()
