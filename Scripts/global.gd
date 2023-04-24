extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Set the IP address and port for the connection
var ip_address: String = "127.0.0.1"
var port: int = 6000
var discord_url = "https://discord.gg/pTGZuaf"

# Create a StreamPeerTCP instance to manage the TCP connection
var tcp_connection: StreamPeerTCP = StreamPeerTCP.new()

# Define the terrain scene or resource that you want to instantiate
var terrain_scene = preload("res://Assets/terrain.tscn")

# Define the player scene or resource that you want to instantiate
var player_scene = preload("res://Assets/player.tscn")

# Define the map scene or resource that you want to instantiate into
var map_scene = preload("res://Assets/map.tscn")

# Add a signal definition at the top of the script
signal message_received(username, message)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check if any data is available to read
	if tcp_connection.get_available_bytes() > 0:
		# Read the data from the socket
		var data = tcp_connection.get_data(tcp_connection.get_available_bytes())
		if data.size() > 0:
			var dstr = data[1].get_string_from_utf8()
			print(dstr.substr(0, 50))
			if (dstr.length() <= 0):
				return
				
			# Parse the JSON payload
			var payload = JSON.parse(dstr)
			print(payload.result["map"])
			if payload.error == OK:
				# Use a match statement to check against the "action" variable
				match payload.result["action"]:
					"map":
						process_map_event(payload.result["map"])
					"move":
						process_move_event(payload.result["ID"], payload.result["X"], payload.result["Y"])
					"spawn_player":
						process_spawn_player_event(payload.result["ID"], payload.result["Name"], payload.result["X"], payload.result["Y"])
					"say":
						process_say_event(payload.result["username"], payload.result["message"])

					_:
						print("Unknown action received: %s" % payload.result["action"])
			else:
				print("Invalid JSON payload received")
		else:
			print("Disconnected from %s:%s" % [ip_address, port])
			# Stop processing to close the connection
			set_process(false)

func process_map_event(map_data):
	for map_object in map_data:
		for map_cell in map_object:
			print(map_object)
			var x = map_cell["x"]
			var y = map_cell["y"]

			# Instantiate a square and add it to the scene at the specified position
			var terrain = terrain_scene.instance()
			terrain.set("TYPE", map_cell["type"]) # Set the TYPE property of the square scene
			terrain.position = Vector2(x, y)
			map_scene.add_child(terrain)
	if get_tree().change_scene(map_scene) != OK:
		print("Failed to Load Map.")


func _exit_tree():
	# Close the connection when the node is removed from the scene tree
	tcp_connection.disconnect_from_host()

# Add this new function after the _ready function
func connect_and_send_username(username: String):
	# Attempt to connect to the IP address and port
	var error = tcp_connection.connect_to_host(ip_address, port)

	if error == OK:
		print("Connected to %s:%s" % [ip_address, port])
		# Send the username to the server
		send_username(username)
		# Keep the connection open
		set_process(true)
	else:
		print("Failed to connect to %s:%s" % [ip_address, port])

# Update the send_username function to remove the username argument
func send_username(username: String):
	print("Sending Username: %s" % [username])
	var data = username.to_utf8()
	var error = tcp_connection.put_data(data)
	if error != OK:
		print("Failed to send username")

# Update the process_spawn_player_event function to include X and Y position arguments
func process_spawn_player_event(player_id, player_name, x, y):
	# Instantiate a square and add it to the scene
	var player = player_scene.instance()
	player.set("ID", player_id) # Set the ID property of the square scene
	player.set("Name", player_name) # Set the Name property of the square scene
	player.position = Vector2(x, y) # Set the X and Y position of the square scene
	map_scene.add_child(player)

# Add this new function after the process_spawn_player_event function
func process_move_event(player_id, x, y):
	# Find the square scene with the matching ID
	for child in map_scene.get_children():
		if child.get("ID", -1) == player_id:
			# Set the new X and Y position for the square scene
			child.position = Vector2(x, y)
			break
# Add this new function after the process_move_event function
func process_say_event(username, message):
	# Trigger the global event by emitting the message_received signal
	emit_signal("message_received", username, message)
# Documentation should be something like this, inside of the chat window
#func _ready():
#    # Replace "TCP_Connection_Node" with the actual node name or path
#    $TCP_Connection_Node.connect("message_received", self, "_on_message_received")
#
#func _on_message_received(username, message):
#    # Handle the received message and username
#    print("%s: %s" % [username, message])
