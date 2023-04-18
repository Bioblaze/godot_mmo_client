extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var remember_me_token
var login_url = "http://localhost:50001/login"
var login_verify_url = "http://localhost:50001/login/verify"
var login_send_url = "http://localhost:50001/send/login/verify"
var register_url = "http://localhost:50001/register"
var register_verify_url = "http://localhost:50001/register/verify"
var register_send_url = "http://localhost:50001/send/register/verify"
var discord_url = "https://discord.gg/pTGZuaf"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Remember Me Loading...")
	var remember_me := File.new()
	if remember_me.file_exists("user://remember_me.json"):
		print("Remember Me Json Exists.. Attempting to Load...")
		remember_me.open("user://remember_me.json", File.READ)
		var d := JSON.parse(remember_me.get_as_text())
		remember_me.close()
		if d.error:
			printerr("Failed to Parse RememberMe Save File.")
		remember_me_token = d.token
		print("Remember Me Token: ", remember_me_token)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
