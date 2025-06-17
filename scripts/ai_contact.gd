extends Node

var client := StreamPeerTCP.new()
var connected := false

var step_requested := false

var mode_label: Label = null

var pause = false

var plr: Node = null
func _ready():
	plr = get_node("/root/Main/SubViewportContainer/Main_Viewport/Player")
	
	mode_label = get_node("/root/Main/Debug-UI/AI")
	mode_label.text = "Mode: AI"
	mode_label.modulate = Color(0,1,0)
	
	Engine.time_scale = 0.0
	set_process(true)
	set_physics_process(true)
	
	var status = client.connect_to_host('127.0.0.1', 9000)
	print("Connecting...")
	if status != OK:
		push_error("Failed to initiate connection: " + str(status))
	
func _process(_delta):
	#print(client.get_status())
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		client.poll()
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED and !connected:
		print("Connected to Python server!")
		connected = true
		step_requested = true
		
	if step_requested:
		step()
	if Input.is_action_just_pressed("toggle_ai_input"):
		toggle_ignore_ai()
		
#Advances the game by 1 frame and then contacts the ai
func step():
	#print("Stepping")
	Engine.time_scale = 1.0  # Temporarily unfreeze
	await get_tree().process_frame  # Wait for idle step
	Engine.time_scale = 0.0
	step_requested = false
	if pause:
		step_requested = true
		return
	if feedback['died'] == true:
		#print("a")
		pause = true
	var data = gather_data()
	var response = send_state_and_get_action(data)
	set_input(response)

var feedback = {
	"enemies_hit" : 0,
	"enemies_defeated" : 0,
	"ult_delets" : 0,
	"bosses_hit" : 0,
	"bosses_defeated" : 0,
	"got_hit" : false,
	"died" : false,
	"won" : false
}

func enemy_to_int(name: String) -> int:
	match(name):
		'basic_enemy' : return 1
		'basic_enemy_side' : return 1
		'basic_enemy_tri' : return 2
		'basic_enemy_side_tri' : return 2
		'kamikaze' : return 3
		'laser' : return 4
		'spinner_bullets' : return 5
		'spinner_laser' : return 6
		'aunn' : return 7
		'narumi' : return 8
		'test_boss' : return 9
	return 0
#Get all info that ai needs
func gather_data() -> Dictionary:
	var ret: Dictionary
	ret["Player"] = {
		"position" : {
			"x" : plr.position.x / 1280.0,
			"y" : plr.position.y / 1080.0
			},
		"hp" : plr.hp/plr.max_hp,
		"ability_charge" : plr.ability_charge/100.0
		}
	var plr_bullets_array: Array = []
	for bullet in get_tree().get_nodes_in_group("player_bullets"):
		plr_bullets_array.append({
			"position" : {
				"x" : bullet.position.x / 1280.0,
				"y" : bullet.position.y / 1080.0
				}
			})
	ret["Player_Bullets"] = plr_bullets_array

	var enemy_bullets_array: Array = []
	for bullet in get_tree().get_nodes_in_group("bullets"):
		enemy_bullets_array.append({
			"position" : {
				"x" : bullet.position.x  / 1280.0,
				"y" : bullet.position.y / 1080.0
				}
			})
	for bullet in get_tree().get_nodes_in_group("bullet"):
		enemy_bullets_array.append({
			"position" : {
				"x" : bullet.position.x  / 1280.0,
				"y" : bullet.position.y / 1080.0
				}
			})
	ret["Enemy_Bullets"] = enemy_bullets_array
	
	var enemy_array: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		enemy_array.append({
			"position" : {
				"type" : enemy_to_int(e.get_script().get_path().get_file().get_basename()),
				"x" : e.position.x / 1280.0,
				"y" : e.position.y / 1080.0
				}
			})
	ret["Enemies"] = enemy_array
	
	var boss_array: Array = []
	for b in get_tree().get_nodes_in_group("bosses"):
		boss_array.append({
			"position" : {
				"type" : enemy_to_int(b.get_script().get_path().get_file().get_basename()),
				"x" : b.position.x / 1280.0,
				"y" : b.position.y / 1080.0,
				"hp" : b.hp / b.max_hp
				}
			})
	ret["Bosses"] = boss_array
	
	ret["Feedback"] = feedback
	
	#Reset feedback after it's used
	feedback = {
		"enemies_hit" : 0,
		"enemies_defeated" : 0,
		"ult_delets" : 0,
		"bosses_hit" : 0,
		"bosses_defeated" : 0,
		"got_hit" : false,
		"died" : false,
		"won" : false
	}
	#print(ret)
	return ret

#Send data and wait for response
func send_state_and_get_action(state: Dictionary) -> Dictionary:
	if client.get_connected_host() != null:
		client.poll()
		#Send data
		var json := JSON.stringify(state)
		#print(json.contains("\n"))
		client.put_utf8_string(json + "\n")  # newline-separated
		#Give python time to process
		OS.delay_msec(1)
		
		#Receive data
		while true:
			var action_str: String = ""
			while client.get_available_bytes() > 0:
				action_str += client.get_utf8_string(client.get_available_bytes())
			if action_str == "":
				#print("Nothing received from server.")
				OS.delay_msec(100)
				continue
			var lines := action_str.split("\n", false)
			for line in lines:
				if line.strip_edges() != "":
					var r = JSON.parse_string(line)
					if r is Dictionary:
						return r
					else:
						print("Invalid JSON received from server. " + action_str)
						OS.delay_msec(100)
	return {}
	
var ignore_ai = false
func toggle_ignore_ai():
	ignore_ai = not ignore_ai
	#make sure it releases all inputs
	Input.action_release("ui_shoot")
	Input.action_release("ui_sneak")
	Input.action_release("ui_ability")
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	
	if ignore_ai:
		mode_label.text = "Mode: Player"
		mode_label.modulate = Color(1,1,0)
	else:
		mode_label.text = "Mode: AI"
		mode_label.modulate = Color(0,1,0)
		
#Sets inputs according to ai response
func set_input(response: Dictionary):
	if not ignore_ai:
		#print(response)
		if response["shoot"]:
			Input.action_press("ui_shoot")
		else:
			Input.action_release("ui_shoot")
		if response["sneak"]:
			Input.action_press("ui_sneak")
		else:
			Input.action_release("ui_sneak")
		if response["ability"]:
			Input.action_press("ui_ability")
		else:
			Input.action_release("ui_ability")
		if response["up"]:
			Input.action_press("ui_up")
		else:
			Input.action_release("ui_up")
		if response["down"]:
			Input.action_press("ui_down")
		else:
			Input.action_release("ui_down")
		if response["left"]:
			Input.action_press("ui_left")
		else:
			Input.action_release("ui_left")
		if response["right"]:
			Input.action_press("ui_right")
		else:
			Input.action_release("ui_right")
	step_requested = true
