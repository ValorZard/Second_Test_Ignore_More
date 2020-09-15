extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		get_node("Login/EnterName").text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		get_node("Login/EnterName").text = desktop_path[desktop_path.size() - 2]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JoinButton_pressed():
	if get_node("Login/EnterName").text == "":
		get_node("Login/ErrorLabel").text = "Invalid name!"
		return

	var ip = get_node("Login/EnterAddress").text
	
	if not ip.is_valid_ip_address():
		get_node("Login/ErrorLabel").text = "Invalid IP address!"
		return

	get_node("Login/ErrorLabel").text = ""
	get_node("Login/HostButton").disabled = true
	get_node("Login/JoinButton").disabled = true

	var player_name = get_node("Login/EnterName").text
	gamestate.join_game(ip, player_name)
	pass # Replace with function body.


func _on_HostButton_pressed():
	if get_node("Login/EnterName").text == "":
		get_node("Login/ErrorLabel").text = "Invalid name!"
		return

	get_node("Login").hide()
	get_node("PlayersReady").show()
	get_node("Login/ErrorLabel").text = ""

	var player_name = get_node("Login/EnterName").text
	gamestate.host_game(player_name)
	refresh_lobby()
	pass # Replace with function body.

func _on_connection_success():
	get_node("Login").hide()
	get_node("PlayersReady").show()

func _on_connection_failed():
	get_node("Login/HostButton").disabled = false
	get_node("Login/JoinButton").disabled = false
	get_node("Login/ErrorLabel").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("Login").show()
	get_node("PlayersReady").hide()
	get_node("Login/HostButton").disabled = false
	get_node("Login/JoinButton").disabled = false

func _on_game_error(errtxt):
	get_node("ErrorDialog").dialog_text = errtxt
	get_node("ErrorDialog").popup_centered_minsize()
	get_node("Login/HostButton").disabled = false
	get_node("Login/JoinButton").disabled = false

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("PlayersReady/PlayerList").clear()
	get_node("PlayersReady/PlayerList").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("PlayersReady/PlayerList").add_item(p)

	get_node("PlayersReady/StartGame").disabled = not get_tree().is_network_server()

func _on_StartGame_pressed():
	gamestate.begin_game()
	pass # Replace with function body.
