extends Node

var client := StreamPeerTCP.new()
var connected := false

var step_requested := false

func _ready():
	Engine.time_scale = 0.0  # Freeze time completely
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
		print("Stepping")
		Engine.time_scale = 1.0  # Temporarily unfreeze
		await get_tree().process_frame  # Wait for idle step
		Engine.time_scale = 0.0
		step_requested = false
		var response = send_state_and_get_action({"a" = 1})
		set_input(response)
	if Input.is_action_pressed("ui_shoot"):
		step_requested = true

func send_state_and_get_action(state: Dictionary) -> Dictionary:
	if client.get_connected_host() != null:
		client.poll()
		var json := JSON.stringify(state)
		client.put_utf8_string(json + "\n")  # newline-separated
		OS.delay_msec(1)
		while true:
			var action_str: String = ""
			while client.get_available_bytes() > 0:
				action_str += client.get_utf8_string(client.get_available_bytes())
			if action_str == "":
				print("Nothing received from server.")
				OS.delay_msec(100)
				continue
			var r = JSON.parse_string(action_str)
			if r is Dictionary:
				return r
			else:
				print("Invalid JSON received from server. " + action_str)
				OS.delay_msec(100)
	return {}
func set_input(response: Dictionary):
	print(response)
	step_requested = true
